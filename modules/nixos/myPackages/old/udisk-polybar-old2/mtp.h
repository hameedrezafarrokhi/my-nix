#ifndef MTP_H
#define MTP_H

/*
 * mtp.h
 *
 * Android/MTP support without gvfs or libmtp linked into this binary.
 * Detection: a udev monitor (added to the daemon's existing poll()
 * set -- one more fd, still 0% idle CPU) watching for USB devices
 * carrying the ID_MTP_DEVICE=1 property. That property is set by the
 * mtp-probe udev rule that ships with libmtp -- which jmtpfs itself
 * depends on, so if jmtpfs is installed, detection works with nothing
 * extra to configure.
 *
 * Mounting: shells out to `jmtpfs <mountpoint> -device=bus,dev`, a
 * real FUSE mount, so ordinary programs (cp, rsync, a terminal, any
 * file manager) can read/write it like any other directory -- not
 * just GIO-aware apps, which is the whole point versus a bare `gio
 * mount`. Unmounting shells out to `fusermount -u`.
 */

typedef struct {
    char *syspath;       /* udev syspath -- stable only while attached, used to dedupe one enumeration pass */
    char *serial;         /* ID_SERIAL_SHORT if available, else "" */
    char *vendor;
    char *model;
    int busnum, devnum;    /* for jmtpfs -device=busnum,devnum when more than one phone is attached */

    int is_mounted;
    char *mount_point;

    char display_name[256];
    char resolved_color[16];

    int usage_valid;         /* statvfs on an MTP FUSE mount is best-effort -- some phones/MTP stacks under-report or don't implement it at all */
    unsigned long long used_bytes, free_bytes, total_bytes;
    int percent_used, percent_free;
} MtpDevice;

typedef struct {
    MtpDevice *items;
    int count;
} MtpDeviceList;

/* Sets up the udev monitor. Call once, before entering the daemon's
 * poll() loop (or before a one-shot mtp_list() call -- harmless
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

/* Full re-enumeration: lists every currently-attached MTP-capable USB
 * device. Preserves mount state for devices that are still attached
 * from the previous list (matched by serial, falling back to
 * bus/dev) -- rebuilding shouldn't forget you already mounted one. */
void mtp_list_build(MtpDeviceList *list, const MtpDeviceList *previous);

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

#endif /* MTP_H */
