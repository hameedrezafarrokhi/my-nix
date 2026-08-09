/*
 * mtp.c
 *
 * See mtp.h for the overall approach (udev detection, jmtpfs
 * mounting, no gvfs/glib/libmtp linked into this binary).
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>
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

static void sanitize_name(const char *in, char *out, size_t outlen) {
    size_t o = 0;
    for (const char *p = in; *p && o + 1 < outlen; p++) {
        unsigned char c = (unsigned char)*p;
        out[o++] = (isalnum(c) || c == '.' || c == '_' || c == '-') ? (char)c : '-';
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

static void mtp_substitute(const char *tmpl, const MtpDevice *d, char *out, size_t outlen) {
    char name[256];
    sanitize_name(d->display_name, name, sizeof(name));
    const char *serial = d->serial[0] ? d->serial : "unknown";

    size_t o = 0;
    for (const char *p = tmpl; *p && o < outlen - 1; ) {
        if (!strncmp(p, "{NAME}", 6)) {
            size_t l = strlen(name); if (o + l >= outlen) l = outlen - 1 - o;
            memcpy(out + o, name, l); o += l; p += 6;
        } else if (!strncmp(p, "{SERIAL}", 8)) {
            size_t l = strlen(serial); if (o + l >= outlen) l = outlen - 1 - o;
            memcpy(out + o, serial, l); o += l; p += 8;
        } else {
            out[o++] = *p++;
        }
    }
    out[o] = '\0';
}

static void spawn_and_wait(char *const argv[], int *exit_code) {
    pid_t pid = fork();
    if (pid == 0) {
        int devnull = open("/dev/null", O_RDWR);
        if (devnull >= 0) {
            dup2(devnull, 0); dup2(devnull, 1); dup2(devnull, 2);
            if (devnull > 2) close(devnull);
        }
        execvp(argv[0], argv);
        _exit(127);
    }
    if (pid < 0) { *exit_code = -1; return; }
    int status = 0;
    waitpid(pid, &status, 0);
    *exit_code = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
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

int mtp_perform_mount(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;

    char substituted[600];
    mtp_substitute(MTP_MOUNT_DIR_TEMPLATE, d, substituted, sizeof(substituted));
    char mountdir[700];
    expand_home(substituted, mountdir, sizeof(mountdir));
    mkdir_recursive(mountdir);

    char busdev[32] = "";
    if (d->busnum > 0 && d->devnum > 0) snprintf(busdev, sizeof(busdev), "-device=%d,%d", d->busnum, d->devnum);

    char *argv[8];
    int ai = 0;
    argv[ai++] = "jmtpfs";
    if (busdev[0]) argv[ai++] = busdev;
    argv[ai++] = mountdir;
    argv[ai] = NULL;

    int code = 0;
    spawn_and_wait(argv, &code);

    if (code != 0) {
        if (out_error) {
            char b[300];
            snprintf(b, sizeof(b),
                     "jmtpfs exited with status %d (phone unlocked and set to file-transfer/MTP mode? "
                     "is jmtpfs installed?)", code);
            *out_error = strdup(b);
        }
        rmdir(mountdir); /* best-effort cleanup of the empty dir we made */
        return 0;
    }

    free(d->mount_point);
    d->mount_point = strdup(mountdir);
    d->is_mounted = 1;
    refresh_usage_one(d);
    resolve_color_one(d);
    return 1;
}

int mtp_perform_unmount(MtpDevice *d, char **out_error) {
    if (out_error) *out_error = NULL;
    if (!d->mount_point) return 0;

    char *argv[4] = { (char *)"fusermount", (char *)"-u", d->mount_point, NULL };
    int code = 0;
    spawn_and_wait(argv, &code);

    if (code != 0) {
        if (out_error) *out_error = strdup("fusermount failed (still busy? close any open files/apps using it)");
        return 0;
    }

    rmdir(d->mount_point);
    free(d->mount_point);
    d->mount_point = NULL;
    d->is_mounted = 0;
    d->usage_valid = 0;
    resolve_color_one(d);
    return 1;
}
