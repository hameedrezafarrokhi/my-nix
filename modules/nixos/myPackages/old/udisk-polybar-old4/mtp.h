#ifndef MTP_H
#define MTP_H

/*
 * mtp.h
 *
 * Android/MTP support without linking glib/gio into this binary
 * ourselves -- we shell out to the `gio` command (same category of
 * dependency as `xdg-open` or a file manager, not a library link).
 *
 * Detection: a udev monitor (added to the daemon's existing poll()
 * set -- one more fd, still 0% idle CPU) watching for USB devices
 * carrying the ID_MTP_DEVICE=1 property, set by the mtp-probe udev
 * rule that ships with libmtp.
 *
 * Mounting: `gio mount mtp://[usb:BUS,DEV]/`, using gvfs's MTP
 * backend -- actively maintained (part of freedesktop.org/GNOME,
 * regular releases, the same code GNOME Files/Nautilus uses for
 * Android transfers every day), and genuinely bidirectional in both
 * directions, unlike the jmtpfs/simple-mtpfs family of abandoned FUSE
 * wrappers this replaced. `gio mount` only creates a *virtual* GIO
 * mount by itself; what actually makes it usable from `cp`/`rsync`/
 * any non-GIO program is gvfs's own FUSE bridge (`gvfsd-fuse`, part
 * of the same `gvfs` package), which mirrors it as a real POSIX path
 * under $XDG_RUNTIME_DIR/gvfs/mtp:host=... -- that's the path this
 * module locates and treats as the phone's "mount point" everywhere
 * else (Open in File Manager, Copy Mount Path, custom entries).
 *
 * Requires the `gvfs` package with its D-Bus service files active
 * (on NixOS: `services.gvfs.enable = true;`). No jmtpfs/simple-mtpfs/
 * go-mtpfs, no dislocker, no MTP-specific FUSE binary at all.
 */

typedef struct {
    char *syspath;       /* udev syspath -- stable only while attached, used to dedupe one enumeration pass */
    char *serial;         /* ID_SERIAL_SHORT if available, else "" */
    char *vendor;
    char *model;
    int busnum, devnum;    /* used to build the mtp://[usb:bus,dev]/ URI passed to `gio mount`, and to disambiguate when more than one phone is attached */

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
