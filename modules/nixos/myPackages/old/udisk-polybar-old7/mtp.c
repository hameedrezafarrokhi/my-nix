/*
 * mtp.c
 *
 * See mtp.h for the overall approach: detection is built-in (udev),
 * mounting is handed off entirely to an external command
 * (MTP_MOUNT_CMD), tracked via state_file.h so Mount and Unmount
 * (possibly different processes, possibly much later) and an unplug-
 * without-unmounting can all find and clean up the right thing.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <dirent.h>
#include <time.h>
#include <libudev.h>

#include "mtp.h"
#include "state_file.h"
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

void mtp_device_key(const MtpDevice *d, char *out, size_t outlen) {
    if (d->serial && d->serial[0]) snprintf(out, outlen, "%s", d->serial);
    else snprintf(out, outlen, "%d:%d", d->busnum, d->devnum);
}

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */

static void sanitize_name(const char *in, char *out, size_t outlen) {
    size_t o = 0;
    for (const char *p = in; *p && o + 1 < outlen; p++) {
        unsigned char c = (unsigned char)*p;
        out[o++] = (isalnum(c) || c == '.' || c == '_' || c == '-') ? (char)c : '_';
    }
    if (o == 0 && outlen > 6) { snprintf(out, outlen, "phone"); return; }
    out[o] = '\0';
}

static void expand_home(const char *path, char *out, size_t outlen) {
    if (path[0] == '~') {
        const char *home = getenv("HOME");
        if (!home || !home[0]) home = "/";
        snprintf(out, outlen, "%s%s", home, path + 1);
    } else {
        snprintf(out, outlen, "%s", path);
    }
}

static void mkdir_recursive(const char *path) {
    char tmp[1024];
    snprintf(tmp, sizeof(tmp), "%s", path);
    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') { *p = '\0'; mkdir(tmp, 0755); *p = '/'; }
    }
    mkdir(tmp, 0755);
}

static int split_ws(char *s, char *argv[], int max) {
    int n = 0;
    char *tok = strtok(s, " \t");
    while (tok && n < max - 1) { argv[n++] = tok; tok = strtok(NULL, " \t"); }
    argv[n] = NULL;
    return n;
}

/* Checked against /proc/mounts rather than trusting a process's exit
 * status or liveness -- the one signal that's true regardless of
 * whether the mount tool stays in the foreground (go-mtpfs) or
 * daemonizes to the background on success (typical libfuse tools). */
static int is_path_mounted(const char *path) {
    FILE *f = fopen("/proc/mounts", "r");
    if (!f) return 0;
    char line[2048];
    int found = 0;
    size_t plen = strlen(path);
    while (fgets(line, sizeof(line), f)) {
        char *sp1 = strchr(line, ' ');
        if (!sp1) continue;
        char *mp = sp1 + 1;
        char *sp2 = strchr(mp, ' ');
        if (!sp2) continue;
        size_t mplen = (size_t)(sp2 - mp);
        if (mplen == plen && strncmp(mp, path, plen) == 0) { found = 1; break; }
    }
    fclose(f);
    return found;
}

static int pid_alive(pid_t pid) {
    return pid > 0 && (kill(pid, 0) == 0 || errno == EPERM);
}

/* Being *registered* in /proc/mounts only means the kernel-level FUSE
 * mount exists -- it says nothing about whether the userspace process
 * serving it is still alive and actually answering requests. A mount
 * whose server died without a clean unmount (crashed, got SIGKILLed,
 * or -- the case that actually bit us -- the MTP device took too long
 * to grant the file-transfer permission prompt and the tool gave up)
 * stays registered as a dead, permanently non-functional "Transport
 * endpoint is not connected" mount, and *that* is what
 * is_path_mounted() alone can't tell apart from a genuinely working
 * one. Actually reading the directory is the only reliable way to
 * know: a dead mount fails an opendir()/readdir() immediately with a
 * real errno (ENOTCONN and friends); a live one succeeds (possibly
 * after a brief, bounded block while its FUSE server catches up, e.g.
 * still finishing the MTP handshake with a slow-to-respond phone --
 * that block is a real (if rare) risk of slightly increasing wall-
 * clock time spent per poll iteration, but it can't produce a wrong
 * answer, unlike trusting /proc/mounts alone did.) */
static int mount_is_functional(const char *path) {
    DIR *dp = opendir(path);
    if (!dp) return 0;
    errno = 0;
    struct dirent *ent = readdir(dp);
    int ok = (ent != NULL) || (errno == 0); /* a genuinely empty dir is fine; a readdir() errno means dead */
    closedir(dp);
    return ok;
}

static int is_path_mounted_and_functional(const char *path) {
    return is_path_mounted(path) && mount_is_functional(path);
}

/* Signals the whole process group, not just `pid` -- every process we
 * spawn here (mount command, scrcpy) is made its own process group
 * leader via setsid() before exec, specifically so this catches any
 * helper processes it spawns too (e.g. scrcpy shelling out to a local
 * adb client) instead of leaving them behind as the "unkillable"
 * orphans a single-PID kill was leaving. Falls back to a plain
 * single-PID kill if the group signal itself fails for some reason. */
static void kill_group(pid_t pid, int sig) {
    if (pid <= 0) return;
    if (kill(-pid, sig) != 0) kill(pid, sig);
}

static long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long)ts.tv_sec * 1000L + ts.tv_nsec / 1000000L;
}

/* Blocking spawn+capture, for short-lived commands only (fusermount)
 * -- NOT for the mount command itself, which may run forever. */
static void spawn_and_wait_capture(char *const argv[], int *exit_code, char *out, size_t outlen) {
    out[0] = '\0';
    int pipefd[2];
    if (pipe(pipefd) != 0) { *exit_code = -1; return; }

    pid_t pid = fork();
    if (pid == 0) {
        close(pipefd[0]);
        dup2(pipefd[1], 1); dup2(pipefd[1], 2);
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
    }
    out[got] = '\0';
    close(pipefd[0]);

    int status = 0;
    waitpid(pid, &status, 0);
    *exit_code = WIFEXITED(status) ? WEXITSTATUS(status) : -1;

    while (got > 0 && (out[got - 1] == '\n' || out[got - 1] == '\r' || out[got - 1] == ' ')) out[--got] = '\0';
}

static void run_fusermount_u(const char *mount_point) {
    char *argv[4] = { (char *)MTP_UNMOUNT_FUSERMOUNT_CMD, (char *)"-u", (char *)mount_point, NULL };
    int code = 0;
    char output[256];
    spawn_and_wait_capture(argv, &code, output, sizeof(output));
    (void)code; /* best-effort -- caller checks is_path_mounted() itself if it needs to know */
}

static void run_fusermount_uz(const char *mount_point) {
    /* Lazy unmount -- detaches the mountpoint from the namespace
     * immediately even if something is still (unresponsively) holding
     * it open, cleaning up the underlying connection once nothing
     * references it anymore. Used as a stronger fallback when a plain
     * -u doesn't clear a dead mount. */
    char *argv[4] = { (char *)MTP_UNMOUNT_FUSERMOUNT_CMD, (char *)"-uz", (char *)mount_point, NULL };
    int code = 0;
    char output[256];
    spawn_and_wait_capture(argv, &code, output, sizeof(output));
    (void)code;
}

/* If `mountdir` has a stale, dead mount registered on it (server
 * process gone without a clean unmount -- see mount_is_functional()'s
 * comment), clears it so a fresh mount attempt can actually succeed
 * instead of every future Mount click silently short-circuiting on
 * the dead entry forever. No-op if nothing's registered there, or if
 * what's registered is genuinely still alive and working. */
static void ensure_not_stale_mounted(const char *mountdir) {
    if (!is_path_mounted(mountdir)) return;
    if (mount_is_functional(mountdir)) return;
    run_fusermount_u(mountdir);
    if (is_path_mounted(mountdir)) run_fusermount_uz(mountdir);
}

/* ------------------------------------------------------------------ */
/* usage / color                                                       */
/* ------------------------------------------------------------------ */

static void refresh_usage_one(MtpDevice *d) {
    d->usage_valid = 0;
    if (!d->is_mounted || !d->mount_point) return;
    struct statvfs vfs;
    if (statvfs(d->mount_point, &vfs) != 0) return;
    if (vfs.f_blocks == 0) return;
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

void mtp_list_build(MtpDeviceList *list) {
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

        char key[64];
        mtp_device_key(&d, key, sizeof(key));

        pid_t mpid = 0;
        char *mp = NULL;
        if (state_get_mtp_mount(key, &mpid, &mp)) {
            if (mp && mp[0] && is_path_mounted(mp)) {
                d.is_mounted = 1;
                d.mount_point = mp;
                d.mount_pid = mpid;
            } else {
                /* stale record -- the mount died without us noticing (crashed FUSE server, manual fusermount, etc) */
                if (mpid > 0 && pid_alive(mpid)) { kill(mpid, SIGTERM); }
                state_remove_mtp_mount(key);
                free(mp);
            }
        }

        pid_t spid = state_get_scrcpy(key);
        if (spid > 0 && !pid_alive(spid)) { state_remove_scrcpy(key); spid = 0; }
        d.scrcpy_pid = spid;

        refresh_usage_one(&d);
        resolve_color_one(&d);

        items = realloc(items, sizeof(MtpDevice) * (count + 1));
        items[count++] = d;
    }

    udev_enumerate_unref(e);
    list->items = items;
    list->count = count;
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

int mtp_perform_mount(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;

    char name[256];
    sanitize_name(d->display_name, name, sizeof(name));
    char parent[1024];
    expand_home(MTP_MOUNT_PARENT_DIR, parent, sizeof(parent));
    char mountdir[1300];
    snprintf(mountdir, sizeof(mountdir), "%s/%s", parent, name);
    mkdir_recursive(mountdir);

    /* Clear out any dead mount left registered on this exact path
     * from a previous attempt (crashed tool, or the phone took too
     * long to grant permission and the tool gave up) -- otherwise the
     * shortcut check right below would trust it and report success
     * without ever actually invoking the mount command this time. */
    ensure_not_stale_mounted(mountdir);

    if (is_path_mounted_and_functional(mountdir)) {
        /* genuinely already mounted and working (e.g. this MtpDevice
         * came from a fresh process and a previous attempt actually
         * succeeded) */
        free(d->mount_point);
        d->mount_point = strdup(mountdir);
        d->is_mounted = 1;
        refresh_usage_one(d);
        resolve_color_one(d);
        return 1;
    }

    char cmdbuf[512];
    snprintf(cmdbuf, sizeof(cmdbuf), "%s", MTP_MOUNT_CMD);
    char *argv[34];
    int n = split_ws(cmdbuf, argv, 32);
    argv[n++] = mountdir;
    argv[n] = NULL;

    int pipefd[2];
    if (pipe(pipefd) != 0) {
        if (out_error) *out_error = strdup("pipe() failed");
        return 0;
    }

    pid_t pid = fork();
    if (pid == 0) {
        close(pipefd[0]);
        dup2(pipefd[1], 1); dup2(pipefd[1], 2);
        int devnull = open("/dev/null", O_RDONLY);
        if (devnull >= 0) { dup2(devnull, 0); if (devnull > 2) close(devnull); }
        if (pipefd[1] > 2) close(pipefd[1]);
        setsid(); /* becomes its own process group leader -- see kill_group()'s comment */
        execvp(argv[0], argv);
        _exit(127);
    }
    if (pid < 0) {
        close(pipefd[0]); close(pipefd[1]);
        if (out_error) *out_error = strdup("fork() failed");
        return 0;
    }
    close(pipefd[1]);
    int flags = fcntl(pipefd[0], F_GETFL, 0);
    fcntl(pipefd[0], F_SETFL, flags | O_NONBLOCK);

    char output[1024] = "";
    size_t out_len = 0;
    int mounted = 0;
    int child_alive = 1;
    int child_exit_code = -1;

    /* Wall-clock elapsed time, not an iteration counter -- checking
     * mount_is_functional() can legitimately block for a bit (see its
     * comment: it's a real read against the mount, which blocks if
     * the FUSE server is alive but still busy, e.g. mid-handshake with
     * a slow-to-respond phone), so an iteration can take noticeably
     * longer than the nominal 150ms sleep below. A naive "150ms *
     * iteration count" counter would silently let the actual wait run
     * far past MTP_MOUNT_TIMEOUT_SEC whenever that happens. */
    long start_ms = now_ms();
    long timeout_ms = (long)MTP_MOUNT_TIMEOUT_SEC * 1000L;

    while (now_ms() - start_ms < timeout_ms) {
        char buf[512];
        ssize_t rn;
        while ((rn = read(pipefd[0], buf, sizeof(buf))) > 0) {
            size_t room = sizeof(output) - 1 - out_len;
            size_t take = (size_t)rn < room ? (size_t)rn : room;
            if (take > 0) { memcpy(output + out_len, buf, take); out_len += take; output[out_len] = '\0'; }
        }

        if (is_path_mounted(mountdir) && mount_is_functional(mountdir)) { mounted = 1; break; }

        if (child_alive) {
            int status = 0;
            int r = waitpid(pid, &status, WNOHANG);
            if (r == pid) {
                child_alive = 0;
                child_exit_code = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
            }
        }
        if (!child_alive) {
            /* one more short grace window: some tools fork to the
             * background right as the kernel-level mount completes */
            usleep(300000);
            if (is_path_mounted(mountdir) && mount_is_functional(mountdir)) mounted = 1;
            break;
        }

        usleep(150000);
    }

    close(pipefd[0]);

    if (mounted) {
        free(d->mount_point);
        d->mount_point = strdup(mountdir);
        d->is_mounted = 1;
        d->mount_pid = child_alive ? pid : 0;

        char key[64];
        mtp_device_key(d, key, sizeof(key));
        state_set_mtp_mount(key, d->mount_pid, mountdir);

        refresh_usage_one(d);
        resolve_color_one(d);
        return 1;
    }

    /* failed -- make sure nothing's left half-running (whole process
     * group, in case the tool spawned helpers of its own) */
    if (child_alive) { kill_group(pid, SIGTERM); usleep(200000); kill_group(pid, SIGKILL); }
    run_fusermount_u(mountdir);
    if (is_path_mounted(mountdir)) run_fusermount_uz(mountdir);
    rmdir(mountdir);

    if (out_error) {
        char b[1300];
        if (child_exit_code == 127) {
            snprintf(b, sizeof(b), "'%s' was not found (check MTP_MOUNT_CMD / PATH)", argv[0]);
        } else if (output[0]) {
            snprintf(b, sizeof(b), "%s: %s", MTP_MOUNT_CMD, output);
        } else if (!child_alive) {
            snprintf(b, sizeof(b),
                     "%s exited (code %d) without ever mounting anything. Phone unlocked and set to "
                     "file-transfer/MTP mode?", MTP_MOUNT_CMD, child_exit_code);
        } else {
            snprintf(b, sizeof(b),
                     "%s is still running but never finished mounting (timed out after %ds) -- likely "
                     "still waiting on the phone's file-transfer permission prompt. Check the phone's "
                     "screen and try again, or raise MTP_MOUNT_TIMEOUT_SEC if it just needs longer.",
                     MTP_MOUNT_CMD, MTP_MOUNT_TIMEOUT_SEC);
        }
        *out_error = strdup(b);
    }
    return 0;
}

int mtp_perform_unmount(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;
    if (!d->mount_point) return 0;

    char mountdir[1300];
    snprintf(mountdir, sizeof(mountdir), "%s", d->mount_point);

    if (d->mount_pid > 0) {
        kill_group(d->mount_pid, SIGTERM);
        usleep(300000);
    }

    char output[512];
    { char *argv[4] = { (char *)MTP_UNMOUNT_FUSERMOUNT_CMD, (char *)"-u", mountdir, NULL };
      int code = 0;
      spawn_and_wait_capture(argv, &code, output, sizeof(output)); }

    if (is_path_mounted(mountdir) && d->mount_pid > 0 && pid_alive(d->mount_pid)) {
        /* still holding on -- SIGKILL the whole group and try once more, then fall back to lazy unmount */
        kill_group(d->mount_pid, SIGKILL);
        usleep(200000);
        char output2[512];
        char *argv2[4] = { (char *)MTP_UNMOUNT_FUSERMOUNT_CMD, (char *)"-u", mountdir, NULL };
        int code2 = 0;
        spawn_and_wait_capture(argv2, &code2, output2, sizeof(output2));
        if (is_path_mounted(mountdir)) run_fusermount_uz(mountdir);
    }

    char key[64];
    mtp_device_key(d, key, sizeof(key));

    if (!is_path_mounted(mountdir)) {
        if (d->mount_pid > 0 && pid_alive(d->mount_pid)) kill_group(d->mount_pid, SIGKILL);
        state_remove_mtp_mount(key);
        rmdir(mountdir);
        free(d->mount_point);
        d->mount_point = NULL;
        d->is_mounted = 0;
        d->mount_pid = 0;
        d->usage_valid = 0;
        resolve_color_one(d);
        return 1;
    }

    if (out_error) {
        char b[900];
        if (output[0]) snprintf(b, sizeof(b), "fusermount -u failed: %s", output);
        else snprintf(b, sizeof(b), "fusermount -u failed -- still busy? close any open files/apps using it");
        *out_error = strdup(b);
    }
    return 0;
}

void mtp_cleanup_by_key(const char *device_key) {
    pid_t pid = 0;
    char *mount_point = NULL;
    if (!state_get_mtp_mount(device_key, &pid, &mount_point)) return;

    if (pid > 0 && pid_alive(pid)) {
        kill_group(pid, SIGTERM);
        usleep(300000);
        if (pid_alive(pid)) kill_group(pid, SIGKILL);
    }
    if (mount_point && mount_point[0]) {
        run_fusermount_u(mount_point);
        if (is_path_mounted(mount_point)) run_fusermount_uz(mount_point);
        rmdir(mount_point);
    }
    state_remove_mtp_mount(device_key);
    free(mount_point);
}

/* ------------------------------------------------------------------ */
/* scrcpy                                                               */
/* ------------------------------------------------------------------ */

int mtp_scrcpy_start(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;
    if (d->scrcpy_pid > 0 && pid_alive(d->scrcpy_pid)) {
        if (out_error) *out_error = strdup("scrcpy is already running for this device");
        return 0;
    }

    char cmdbuf[512];
    snprintf(cmdbuf, sizeof(cmdbuf), "%s", SCRCPY_CMD);
    char *argv[34];
    int n = split_ws(cmdbuf, argv, 30);
    if (d->serial[0]) { argv[n++] = (char *)"-s"; argv[n++] = d->serial; }
    argv[n] = NULL;

    pid_t pid = fork();
    if (pid == 0) {
        setsid();
        int devnull = open("/dev/null", O_RDWR);
        if (devnull >= 0) { dup2(devnull, 0); dup2(devnull, 1); dup2(devnull, 2); if (devnull > 2) close(devnull); }
        execvp(argv[0], argv);
        _exit(127);
    }
    if (pid < 0) {
        if (out_error) *out_error = strdup("fork() failed");
        return 0;
    }

    usleep(400000);
    int status = 0;
    int reaped = waitpid(pid, &status, WNOHANG);
    if (reaped == pid) {
        int code = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
        if (out_error) {
            char b[256];
            if (code == 127) snprintf(b, sizeof(b), "'%s' was not found (check SCRCPY_CMD / PATH)", argv[0]);
            else snprintf(b, sizeof(b), "scrcpy exited immediately (exit %d) -- USB debugging authorized on the device?", code);
            *out_error = strdup(b);
        }
        return 0;
    }

    d->scrcpy_pid = pid;
    char key[64];
    mtp_device_key(d, key, sizeof(key));
    state_set_scrcpy(key, pid);
    return 1;
}

int mtp_scrcpy_stop(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;
    if (d->scrcpy_pid <= 0) return 0;

    kill_group(d->scrcpy_pid, SIGTERM);
    usleep(300000);
    if (pid_alive(d->scrcpy_pid)) kill_group(d->scrcpy_pid, SIGKILL);

    char key[64];
    mtp_device_key(d, key, sizeof(key));
    state_remove_scrcpy(key);
    d->scrcpy_pid = 0;
    return 1;
}

void mtp_scrcpy_cleanup_by_key(const char *device_key) {
    pid_t pid = state_get_scrcpy(device_key);
    if (pid > 0) {
        if (pid_alive(pid)) {
            kill_group(pid, SIGTERM);
            usleep(300000);
            if (pid_alive(pid)) kill_group(pid, SIGKILL);
        }
        state_remove_scrcpy(device_key);
    }
}
