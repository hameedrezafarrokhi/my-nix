/*
 * mtp.c
 *
 * See mtp.h for the overall approach (udev detection, gvfs/gio
 * mounting via the `gio` CLI -- no glib/gio/libmtp linked into this
 * binary ourselves).
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <libudev.h>

#include "mtp.h"
#include "config.h"

static struct udev *g_udev = NULL;
static struct udev_monitor *g_mon = NULL;

int mtp_init(void) {
#if ENABLE_MTP
    g_udev = udev_new();
    if (!g_udev) return 0;
    g_mon = udev_monitor_new_from_netlink(g_udev, "udev");
    if (!g_mon) return 0;
    udev_monitor_filter_add_match_subsystem_devtype(g_mon, "usb", "usb_device");
    udev_monitor_enable_receiving(g_mon);
    return 1;
#else
    return 0;
#endif
}

int mtp_monitor_fd(void) {
    if (!g_mon) return -1;
    return udev_monitor_get_fd(g_mon);
}

void mtp_monitor_drain(void) {
    if (!g_mon) return;
    struct udev_device *dev;
    while ((dev = udev_monitor_receive_device(g_mon)) != NULL) udev_device_unref(dev);
}

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */

static const char *runtime_dir(void) {
    const char *r = getenv("XDG_RUNTIME_DIR");
    if (r && r[0]) return r;
    static char fallback[64];
    snprintf(fallback, sizeof(fallback), "/run/user/%d", (int)getuid());
    return fallback;
}

/* gvfs's FUSE mirror directory names are the mount URI's authority
 * component, percent-encoded -- e.g. host "[usb:001,004]" becomes
 * directory "mtp:host=%5Busb%3A001%2C004%5D". Only these four
 * characters ever appear in the host strings we build, so a small
 * fixed table covers it. */
static void percent_encode_host(const char *host, char *out, size_t outlen) {
    size_t o = 0;
    for (const char *p = host; *p && o + 4 < outlen; p++) {
        switch (*p) {
            case '[': memcpy(out + o, "%5B", 3); o += 3; break;
            case ']': memcpy(out + o, "%5D", 3); o += 3; break;
            case ':': memcpy(out + o, "%3A", 3); o += 3; break;
            case ',': memcpy(out + o, "%2C", 3); o += 3; break;
            default:  out[o++] = *p; break;
        }
    }
    out[o] = '\0';
}

/* Snapshots the (non-hidden) entry names directly under `dir` -- used
 * to diff before/after a `gio mount` and catch the new mtp:host=...
 * directory even if the exact percent-encoding above ever drifts from
 * gvfs's actual convention. Missing directory (gvfsd-fuse not started
 * yet) is just an empty snapshot, not an error. */
static void snapshot_gvfs_dirs(const char *dir, char names[][256], int *count, int max) {
    *count = 0;
    DIR *dp = opendir(dir);
    if (!dp) return;
    struct dirent *ent;
    while (*count < max && (ent = readdir(dp)) != NULL) {
        if (ent->d_name[0] == '.') continue;
        snprintf(names[*count], 256, "%s", ent->d_name);
        (*count)++;
    }
    closedir(dp);
}

/* Runs argv, waits for it, and captures its combined stdout+stderr
 * (truncated to outlen-1 bytes) into `out` -- unlike a devnull'd
 * spawn, this lets failure messages show the *real* reason `gio`
 * failed instead of a guess. `*exit_code` is -1 if the process
 * couldn't even be started/exec'd; note that a failed execvp() itself
 * produces no output (it happens after fork, before anything could
 * write to the pipe) and exits with status 127 -- callers should
 * treat exactly 127 as "command not found" specifically. */
static void spawn_and_capture(char *const argv[], int *exit_code, char *out, size_t outlen) {
    out[0] = '\0';
    int pipefd[2];
    if (pipe(pipefd) != 0) { *exit_code = -1; return; }

    pid_t pid = fork();
    if (pid == 0) {
        close(pipefd[0]);
        dup2(pipefd[1], 1);
        dup2(pipefd[1], 2);
        int devnull = open("/dev/null", O_RDONLY);
        if (devnull >= 0) { dup2(devnull, 0); if (devnull > 2) close(devnull); }
        if (pipefd[1] > 2) close(pipefd[1]);
        execvp(argv[0], argv);
        _exit(127);
    }
    if (pid < 0) { close(pipefd[0]); close(pipefd[1]); *exit_code = -1; return; }
    close(pipefd[1]);

    size_t got = 0;
    ssize_t n;
    char buf[512];
    while ((n = read(pipefd[0], buf, sizeof(buf))) > 0) {
        size_t room = outlen - 1 - got;
        size_t take = (size_t)n < room ? (size_t)n : room;
        if (take > 0) { memcpy(out + got, buf, take); got += take; }
        if (room == 0) { /* keep draining so the child doesn't block on a full pipe, just stop storing */ }
    }
    out[got] = '\0';
    close(pipefd[0]);

    int status = 0;
    waitpid(pid, &status, 0);
    *exit_code = WIFEXITED(status) ? WEXITSTATUS(status) : -1;

    /* trim trailing whitespace/newlines for tidier notifications */
    while (got > 0 && (out[got - 1] == '\n' || out[got - 1] == '\r' || out[got - 1] == ' ')) out[--got] = '\0';
}

static void refresh_usage_one(MtpDevice *d) {
    d->usage_valid = 0;
    if (!d->is_mounted || !d->mount_point) return;
    struct statvfs vfs;
    if (statvfs(d->mount_point, &vfs) != 0) return;
    if (vfs.f_blocks == 0) return; /* some MTP/FUSE stacks report this instead of failing -- treat as "no data" */
    unsigned long long total = (unsigned long long)vfs.f_blocks * (unsigned long long)vfs.f_frsize;
    unsigned long long free_avail = (unsigned long long)vfs.f_bavail * (unsigned long long)vfs.f_frsize;
    unsigned long long used = total > free_avail ? total - free_avail : 0;
    d->total_bytes = total;
    d->free_bytes = free_avail;
    d->used_bytes = used;
    d->percent_used = total ? (int)((used * 100ULL) / total) : 0;
    d->percent_free = 100 - d->percent_used;
    d->usage_valid = 1;
}

static void resolve_color_one(MtpDevice *d) {
    if (!d->is_mounted) {
        snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", DEVICE_COLOR_UNMOUNTED);
        return;
    }
    if (MTP_COLOR_MODE == COLOR_MODE_RAMP && d->usage_valid) {
        const char *chosen = SPACE_RAMP[SPACE_RAMP_COUNT - 1].color;
        for (int i = 0; i < SPACE_RAMP_COUNT; i++) {
            if (d->percent_free >= SPACE_RAMP[i].min_percent_free) { chosen = SPACE_RAMP[i].color; break; }
        }
        snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", chosen);
        return;
    }
    snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", DEVICE_COLOR_CONSTANT);
}

/* ------------------------------------------------------------------ */
/* enumeration                                                          */
/* ------------------------------------------------------------------ */

void mtp_list_build(MtpDeviceList *list, const MtpDeviceList *previous) {
    list->items = NULL;
    list->count = 0;

#if ENABLE_MTP
    if (!g_udev) g_udev = udev_new();
    if (!g_udev) return;

    struct udev_enumerate *e = udev_enumerate_new(g_udev);
    if (!e) return;
    udev_enumerate_add_match_subsystem(e, "usb");
    udev_enumerate_scan_devices(e);

    MtpDevice *items = NULL;
    int count = 0;

    struct udev_list_entry *entry;
    for (entry = udev_enumerate_get_list_entry(e); entry; entry = udev_list_entry_get_next(entry)) {
        const char *syspath = udev_list_entry_get_name(entry);
        struct udev_device *dev = udev_device_new_from_syspath(g_udev, syspath);
        if (!dev) continue;

        const char *devtype = udev_device_get_devtype(dev);
        const char *is_mtp = udev_device_get_property_value(dev, "ID_MTP_DEVICE");
        if (!devtype || strcmp(devtype, "usb_device") != 0 || !is_mtp || strcmp(is_mtp, "1") != 0) {
            udev_device_unref(dev);
            continue;
        }

        MtpDevice d;
        memset(&d, 0, sizeof(d));
        d.syspath = strdup(syspath);

        const char *serial = udev_device_get_property_value(dev, "ID_SERIAL_SHORT");
        d.serial = strdup(serial ? serial : "");

        const char *vendor = udev_device_get_property_value(dev, "ID_VENDOR_FROM_DATABASE");
        if (!vendor) vendor = udev_device_get_property_value(dev, "ID_VENDOR");
        d.vendor = strdup(vendor ? vendor : "");

        const char *model = udev_device_get_property_value(dev, "ID_MODEL_FROM_DATABASE");
        if (!model) model = udev_device_get_property_value(dev, "ID_MODEL");
        d.model = strdup(model ? model : "");

        const char *busnum = udev_device_get_property_value(dev, "BUSNUM");
        const char *devnum = udev_device_get_property_value(dev, "DEVNUM");
        d.busnum = busnum ? atoi(busnum) : 0;
        d.devnum = devnum ? atoi(devnum) : 0;

        udev_device_unref(dev);

        if (d.vendor[0] && d.model[0]) snprintf(d.display_name, sizeof(d.display_name), "%s %s", d.vendor, d.model);
        else if (d.model[0]) snprintf(d.display_name, sizeof(d.display_name), "%s", d.model);
        else snprintf(d.display_name, sizeof(d.display_name), "MTP Device");

        if (previous) {
            for (int i = 0; i < previous->count; i++) {
                MtpDevice *p = &previous->items[i];
                int same = (d.serial[0] && p->serial[0] && !strcmp(d.serial, p->serial)) ||
                           (!d.serial[0] && !p->serial[0] && p->busnum == d.busnum && p->devnum == d.devnum);
                if (same && p->is_mounted) {
                    d.is_mounted = 1;
                    d.mount_point = p->mount_point ? strdup(p->mount_point) : NULL;
                }
                if (same) break;
            }
        }

        refresh_usage_one(&d);
        resolve_color_one(&d);

        items = realloc(items, sizeof(MtpDevice) * (count + 1));
        items[count++] = d;
    }

    udev_enumerate_unref(e);
    list->items = items;
    list->count = count;
#else
    (void)previous;
#endif
}

void mtp_list_free(MtpDeviceList *list) {
    for (int i = 0; i < list->count; i++) {
        free(list->items[i].syspath);
        free(list->items[i].serial);
        free(list->items[i].vendor);
        free(list->items[i].model);
        free(list->items[i].mount_point);
    }
    free(list->items);
    list->items = NULL;
    list->count = 0;
}

MtpDevice *mtp_list_find(MtpDeviceList *list, const char *serial_or_busdev) {
    if (!serial_or_busdev || !serial_or_busdev[0]) return NULL;
    for (int i = 0; i < list->count; i++) {
        if (list->items[i].serial[0] && !strcmp(list->items[i].serial, serial_or_busdev)) return &list->items[i];
        char bd[32];
        snprintf(bd, sizeof(bd), "%d:%d", list->items[i].busnum, list->items[i].devnum);
        if (!strcmp(bd, serial_or_busdev)) return &list->items[i];
    }
    return NULL;
}

void mtp_list_refresh_usage(MtpDeviceList *list) {
    for (int i = 0; i < list->count; i++) {
        refresh_usage_one(&list->items[i]);
        resolve_color_one(&list->items[i]);
    }
}

/* ------------------------------------------------------------------ */
/* mount / unmount                                                      */
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/* mount / unmount                                                      */
/* ------------------------------------------------------------------ */

static void build_mtp_uri(const MtpDevice *d, char *host, size_t hostlen, char *uri, size_t urilen) {
    snprintf(host, hostlen, "[usb:%03d,%03d]", d->busnum, d->devnum);
    snprintf(uri, urilen, "mtp://%s/", host);
}

int mtp_perform_mount(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;

    char host[64], uri[128];
    build_mtp_uri(d, host, sizeof(host), uri, sizeof(uri));

    /* "Unable to open MTP device" from gvfs/libmtp almost always
     * means something else already has the USB interface claimed --
     * a previous half-finished gvfs mount, or (very commonly, if
     * you've been testing other MTP tools on the same phone) a
     * leftover jmtpfs/simple-mtpfs process that never released it.
     * libmtp only allows one claimant at a time. A quiet best-effort
     * `gio mount -u` first clears our own previous stale attempts
     * before trying again; it can't do anything about a stray
     * process from a different tool still holding the device open --
     * if mounting keeps failing with this exact error, check for one
     * (`pgrep -a jmtpfs`, `pgrep -a simple-mtpfs`) and unplug/replug
     * the phone. */
    char *argv_precleanup[5] = { (char *)GIO_CMD, (char *)"mount", (char *)"-u", uri, NULL };
    int precleanup_code = 0;
    char precleanup_output[256];
    spawn_and_capture(argv_precleanup, &precleanup_code, precleanup_output, sizeof(precleanup_output));
    (void)precleanup_code; (void)precleanup_output; /* deliberately ignored -- best-effort cleanup only */

    char gvfsdir[300];
    snprintf(gvfsdir, sizeof(gvfsdir), "%s/gvfs", runtime_dir());

    static char before[64][256];
    int n_before = 0;
    snapshot_gvfs_dirs(gvfsdir, before, &n_before, 64);

    char *argv[4] = { (char *)GIO_CMD, (char *)"mount", uri, NULL };
    int code = 0;
    char output[1024];
    spawn_and_capture(argv, &code, output, sizeof(output));

    if (code != 0) {
        if (out_error) {
            char b[1400];
            if (code == 127) {
                snprintf(b, sizeof(b),
                         "the '%s' command was not found in this process's PATH. If gio works fine "
                         "in a terminal, set GIO_CMD in config.h to its absolute path (run `which gio` "
                         "in a normal terminal to find it) and rebuild.", GIO_CMD);
            } else if (output[0] && strcasestr(output, "unable to open")) {
                snprintf(b, sizeof(b),
                         "%s -- something else likely has the USB interface claimed already "
                         "(a stray jmtpfs/simple-mtpfs process from earlier testing is the usual "
                         "culprit: check `pgrep -a jmtpfs`, or just unplug and replug the phone).",
                         output);
            } else if (output[0]) {
                snprintf(b, sizeof(b), "gio mount failed (exit %d): %s", code, output);
            } else {
                snprintf(b, sizeof(b),
                         "gio mount failed (exit %d, no output). Phone unlocked and set to "
                         "file-transfer/MTP mode? Is the gvfs package's D-Bus service active?", code);
            }
            *out_error = strdup(b);
        }
        return 0;
    }

    /* Locate the FUSE mirror path: try the known naming convention
     * first (fast path, usually already there by the time `gio
     * mount` returns), then fall back to diffing the directory
     * listing for up to ~3s in case gvfsd-fuse needs a moment or the
     * naming convention ever drifts from what we assumed above. */
    char encoded[128];
    percent_encode_host(host, encoded, sizeof(encoded));
    char candidate[600];
    snprintf(candidate, sizeof(candidate), "%s/mtp:host=%s", gvfsdir, encoded);

    char found[600] = "";
    for (int attempt = 0; attempt < 20 && !found[0]; attempt++) {
        struct stat st;
        if (stat(candidate, &st) == 0 && S_ISDIR(st.st_mode)) {
            snprintf(found, sizeof(found), "%s", candidate);
            break;
        }

        static char after[64][256];
        int n_after = 0;
        snapshot_gvfs_dirs(gvfsdir, after, &n_after, 64);
        for (int i = 0; i < n_after; i++) {
            if (strncmp(after[i], "mtp:host=", 9) != 0) continue;
            int seen = 0;
            for (int j = 0; j < n_before; j++) {
                if (!strcmp(after[i], before[j])) { seen = 1; break; }
            }
            if (!seen) { snprintf(found, sizeof(found), "%s/%s", gvfsdir, after[i]); break; }
        }
        if (!found[0]) usleep(150000);
    }

    d->is_mounted = 1; /* the gio mount itself succeeded either way */

    if (!found[0]) {
        free(d->mount_point);
        d->mount_point = NULL;
        if (out_error) *out_error = strdup(
            "mounted via gio, but couldn't locate its FUSE path under $XDG_RUNTIME_DIR/gvfs -- "
            "is gvfsd-fuse running? Unmount still works; try a GIO-aware file manager "
            "(Nautilus, GNOME Files) to browse it in the meantime.");
        return 0;
    }

    free(d->mount_point);
    d->mount_point = strdup(found);
    refresh_usage_one(d);
    resolve_color_one(d);
    return 1;
}

int mtp_perform_unmount(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;

    char host[64], uri[128];
    build_mtp_uri(d, host, sizeof(host), uri, sizeof(uri));

    char *argv[5] = { (char *)GIO_CMD, (char *)"mount", (char *)"-u", uri, NULL };
    int code = 0;
    char output[1024];
    spawn_and_capture(argv, &code, output, sizeof(output));

    if (code != 0) {
        if (out_error) {
            char b[1400];
            if (code == 127) {
                snprintf(b, sizeof(b), "the '%s' command was not found in this process's PATH", GIO_CMD);
            } else if (output[0]) {
                snprintf(b, sizeof(b), "gio mount -u failed (exit %d): %s", code, output);
            } else {
                snprintf(b, sizeof(b), "gio mount -u failed (exit %d, no output) -- still busy?", code);
            }
            *out_error = strdup(b);
        }
        return 0;
    }

    free(d->mount_point);
    d->mount_point = NULL;
    d->is_mounted = 0;
    d->usage_valid = 0;
    resolve_color_one(d);
    return 1;
}
