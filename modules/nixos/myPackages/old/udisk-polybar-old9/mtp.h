#ifndef MTP_H
#define MTP_H

#include <sys/types.h> /* pid_t */

/*
 * mtp.h
 *
 * Android/MTP support. Detection is built-in (udev, watching for the
 * ID_MTP_DEVICE=1 property set by libmtp's mtp-probe rule -- folded
 * into the daemon's poll() set, still 0% idle CPU).
 *
 * Mounting is NOT built-in anymore -- every in-house attempt
 * (jmtpfs, then gvfs/gio) had real problems on real hardware, so
 * rather than a third attempt, this hands mounting off entirely to
 * an external command you choose (MTP_MOUNT_CMD in config.h,
 * defaulting to go-mtpfs). This module's job is just: run that
 * command with the right mount point, track the process so Unmount
 * (from any process, possibly much later) and an unplug-without-
 * unmounting can both clean it up properly (SIGTERM if we still have
 * a live PID, then always `fusermount -u` regardless), and provide
 * the dedicated Android menu (upload/download/scrcpy/etc) around it.
 */

typedef struct {
    char *syspath;       /* udev syspath -- stable only while attached, used to dedupe one enumeration pass */
    char *serial;         /* ID_SERIAL_SHORT if available, else "" */
    char *vendor;
    char *model;
    int busnum, devnum;    /* disambiguates when more than one phone is attached; also the device_key fallback when there's no serial */

    int is_mounted;
    char *mount_point;
    pid_t mount_pid;        /* the PID we launched MTP_MOUNT_CMD as, or 0 if unknown (e.g. it daemonized, or this MtpDevice came from a fresh process that only has the state file's record) -- 0 is harmless, see mtp.h's top comment */

    pid_t scrcpy_pid;       /* 0 if scrcpy isn't currently running for this device */

    char display_name[256];
    char resolved_color[16];

    int usage_valid;         /* statvfs on the mount is best-effort -- some phones/MTP stacks under-report or don't implement it at all */
    unsigned long long used_bytes, free_bytes, total_bytes;
    int percent_used, percent_free;
} MtpDevice;

typedef struct {
    MtpDevice *items;
    int count;
} MtpDeviceList;

/* Sets up the udev monitor. Call once, before entering the daemon's
 * poll() loop (or before a one-shot mtp_list_build() call -- harmless
 * either way, just needed once per process). Returns 1 on success, 0
 * if udev/libudev isn't available (treated as "no MTP support this
 * run", not fatal -- disk functionality is unaffected). */
int mtp_init(void);

/* The udev monitor's fd, for the caller's poll() set. Only valid
 * after a successful mtp_init(). */
int mtp_monitor_fd(void);

/* Drains pending udev events after the monitor fd goes readable.
 * Doesn't need to inspect them individually -- any event on this
 * filter means "re-enumerate", same debounce-then-rebuild shape as
 * the UDisks signal path in daemon.c. */
void mtp_monitor_drain(void);

/* Fills `out` (at least 64 bytes) with this device's identity key --
 * its serial if it reported one, else "busnum:devnum" -- used
 * everywhere a device needs to be looked up in the persistent mount/
 * scrcpy tracking (state_file.h), so every caller agrees on the same
 * key. */
void mtp_device_key(const MtpDevice *d, char *out, size_t outlen);

/* Full re-enumeration: lists every currently-attached MTP-capable USB
 * device, with is_mounted/mount_point/mount_pid populated from the
 * persistent state file (so this is correct even in a fresh one-shot
 * process that never saw the mount happen) and scrcpy_pid similarly. */
void mtp_list_build(MtpDeviceList *list);

void mtp_list_free(MtpDeviceList *list);
MtpDevice *mtp_list_find(MtpDeviceList *list, const char *serial_or_busdev);

/* Re-runs statvfs() on every already-mounted phone -- the cheap path
 * for periodic/manual refresh, mirrors device_list_refresh_usage(). */
void mtp_list_refresh_usage(MtpDeviceList *list);

/* Mount/unmount. `d` is updated in place on success. Returns 1/0.
 * No confirmation dialog, no notification -- callers (actions.c)
 * layer those on, same convention as action_perform_mount(). */
int mtp_perform_mount(MtpDevice *d, char **out_error);
int mtp_perform_unmount(MtpDevice *d, char **out_error);

/* Cleans up a mount purely from its device_key -- SIGTERM's the
 * tracked PID if there is one, always runs `fusermount -u` on the
 * tracked mount point, clears the state entry. Used when a phone
 * disappears (unplugged) while still recorded as mounted -- at that
 * point udev can no longer tell us anything about the device, so
 * there's no MtpDevice to call mtp_perform_unmount() on, only the
 * device_key that used to identify it. */
void mtp_cleanup_by_key(const char *device_key);

/* scrcpy: launches/kills SCRCPY_CMD for this device (adds `-s
 * <serial>` automatically when the device has one, so multiple
 * attached phones don't collide), tracking the PID the same way
 * mount tracking works. Returns 1 on success starting/stopping, 0 on
 * failure (e.g. scrcpy not found -- *out_error set either way with a
 * detail message on failure only). `d->scrcpy_pid` is updated in
 * place. */
int mtp_scrcpy_start(MtpDevice *d, char **out_error);
int mtp_scrcpy_stop(MtpDevice *d, char **out_error);

/* Cleans up a tracked scrcpy process purely from its device_key, the
 * same "device is already gone, only the key survives" situation
 * mtp_cleanup_by_key() handles for mounts -- used by the daemon's
 * unplug sweep. */
void mtp_scrcpy_cleanup_by_key(const char *device_key);

#endif /* MTP_H */
