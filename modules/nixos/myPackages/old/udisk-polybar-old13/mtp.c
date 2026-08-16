/*
 * mtp.c
 *
 * See mtp.h: detection + scrcpy management only. No mounting logic
 * of any kind lives here -- MTP_MOUNT_SHELL_CMD/MTP_UNMOUNT_SHELL_CMD
 * are run by actions.c exactly like a custom menu entry.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/statvfs.h>
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

void mtp_fixed_mount_dir(char *out, size_t outlen) {
    const char *path = MTP_MOUNT_PARENT_DIR;
    if (path[0] == '~') {
        const char *home = getenv("HOME");
        if (!home || !home[0]) home = "/";
        snprintf(out, outlen, "%s%s", home, path + 1);
    } else {
        snprintf(out, outlen, "%s", path);
    }
}

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */

static int pid_alive(pid_t pid) {
    return pid > 0 && (kill(pid, 0) == 0 || errno == EPERM);
}

/* Signals the whole process group, not just `pid` -- scrcpy is made
 * its own process group leader via setpgid(0,0) before exec,
 * specifically so this catches any helper processes it spawns too
 * (e.g. a local adb client) instead of leaving them behind. Falls
 * back to a plain single-PID kill if the group signal fails. */
static void kill_group(pid_t pid, int sig) {
    if (pid <= 0) return;
    if (kill(-pid, sig) != 0) kill(pid, sig);
}

static int split_ws(char *s, char *argv[], int max) {
    int n = 0;
    char *tok = strtok(s, " \t");
    while (tok && n < max - 1) { argv[n++] = tok; tok = strtok(NULL, " \t"); }
    argv[n] = NULL;
    return n;
}

/* ------------------------------------------------------------------ */
/* usage / color -- opportunistic only, see mtp_fixed_mount_dir()      */
/* ------------------------------------------------------------------ */

static void refresh_usage_one(MtpDevice *d) {
    d->usage_valid = 0;
    char mountdir[1300];
    mtp_fixed_mount_dir(mountdir, sizeof(mountdir));
    struct statvfs vfs;
    if (statvfs(mountdir, &vfs) != 0) return;
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
        setpgid(0, 0);
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
