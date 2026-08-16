#ifndef MTP_H
#define MTP_H

#include <sys/types.h> /* pid_t */

/*
 * mtp.h
 *
 * Detection only -- attachment/removal via a udev monitor (folded
 * into the daemon's poll() set, still 0% idle CPU), watching for USB
 * devices carrying the ID_MTP_DEVICE=1 property (set by libmtp's
 * mtp-probe udev rule).
 *
 * Mounting/unmounting is NOT handled here, or anywhere in this
 * module, at all -- MTP_MOUNT_SHELL_CMD / MTP_UNMOUNT_SHELL_CMD
 * (config.h) are run exactly like any other menu entry, with no
 * MTP-specific behavior wrapped around them: no success/failure
 * detection, no process tracking, no state file. That's deliberate --
 * every attempt at owning the actual mount step caused more problems
 * than it solved.
 *
 * scrcpy is the one exception -- still fully managed here (spawn/
 * stop/track/auto-cleanup-on-unplug), since it's unrelated to
 * mounting (talks to the phone over its own ADB/USB connection).
 */

typedef struct {
    char *syspath;       /* udev syspath -- stable only while attached, used to dedupe one enumeration pass */
    char *serial;         /* ID_SERIAL_SHORT if available, else "" */
    char *vendor;
    char *model;
    int busnum, devnum;    /* disambiguates when more than one phone is attached; also the device_key fallback when there's no serial */

    pid_t scrcpy_pid;       /* 0 if scrcpy isn't currently running for this device */

    char display_name[256];
    char resolved_color[16];

    /* Opportunistic only -- see MTP_MOUNT_PARENT_DIR's comment in
     * config.h. A statvfs() on that fixed path, nothing more; never
     * used to decide anything about Mount/Unmount. */
    int usage_valid;
    unsigned long long used_bytes, free_bytes, total_bytes;
    int percent_used, percent_free;
} MtpDevice;

typedef struct {
    MtpDevice *items;
    int count;
} MtpDeviceList;

/* Sets up the udev monitor. Call once, before entering the daemon's
 * poll() loop (or before a one-shot mtp_list_build() call). Returns
 * 1 on success, 0 if udev/libudev isn't available (treated as "no
 * MTP support this run", not fatal). */
int mtp_init(void);

/* The udev monitor's fd, for the caller's poll() set. Only valid
 * after a successful mtp_init(). */
int mtp_monitor_fd(void);

/* Drains pending udev events after the monitor fd goes readable. */
void mtp_monitor_drain(void);

/* Fills `out` (at least 64 bytes) with this device's identity key --
 * its serial if it reported one, else "busnum:devnum" -- used for
 * scrcpy process tracking (state_file.h) and for -i/--mtp CLI
 * lookups, so every caller agrees on the same key. */
void mtp_device_key(const MtpDevice *d, char *out, size_t outlen);

/* Expands MTP_MOUNT_PARENT_DIR (config.h) into `out` -- the one fixed
 * path used for opportunistic usage stats, Open in File Manager,
 * Copy Mount Path, and as the phone-side root for Download/Upload.
 * Used exactly as configured; nothing appended. */
void mtp_fixed_mount_dir(char *out, size_t outlen);

/* Full re-enumeration: lists every currently-attached MTP-capable USB
 * device, with usage_valid/used/free/total populated opportunistically
 * (see mtp_fixed_mount_dir()'s comment) and scrcpy_pid from the
 * scrcpy process tracker. */
void mtp_list_build(MtpDeviceList *list);

void mtp_list_free(MtpDeviceList *list);
MtpDevice *mtp_list_find(MtpDeviceList *list, const char *serial_or_busdev);

/* Re-runs statvfs() opportunistically -- the cheap path for periodic/
 * manual refresh, mirrors device_list_refresh_usage(). */
void mtp_list_refresh_usage(MtpDeviceList *list);

/* scrcpy: launches/kills SCRCPY_CMD for this device (adds `-s
 * <serial>` automatically when the device has one, so multiple
 * attached phones don't collide), tracking the PID. Returns 1 on
 * success starting/stopping, 0 on failure (e.g. scrcpy not found --
 * *out_error set either way with a detail message on failure only).
 * `d->scrcpy_pid` is updated in place. */
int mtp_scrcpy_start(MtpDevice *d, char **out_error);
int mtp_scrcpy_stop(MtpDevice *d, char **out_error);

/* Cleans up a tracked scrcpy process purely from its device_key (the
 * phone is already gone by the time this is needed, so there's no
 * MtpDevice left to call mtp_scrcpy_stop() on) -- used by the
 * daemon's unplug sweep. */
void mtp_scrcpy_cleanup_by_key(const char *device_key);

#endif /* MTP_H */
