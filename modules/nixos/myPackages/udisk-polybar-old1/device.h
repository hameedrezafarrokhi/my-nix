#ifndef DEVICE_H
#define DEVICE_H

/*
 * device.h
 *
 * Turns the raw UDisks object list (udisks.h) into what the rest of
 * the program actually deals with: filtered, classified as
 * internal/external, joined with DEVICE_OVERRIDES, and (for mounted
 * filesystems) a statvfs()-based usage ballpark. Nothing in here
 * talks D-Bus directly except by calling into udisks.c.
 */

typedef struct {
    char *object_path;        /* UDisks block object path -- the {ID} used everywhere */
    char *drive_object_path;  /* may be NULL (e.g. loop devices) */

    char *device_node;        /* /dev/sdb1 */
    char *label;               /* may be "" */
    char *uuid;                /* may be "" */
    char *fs_type;              /* "ext4", "vfat", "ntfs", ... */
    unsigned long long size_bytes;
    int read_only;
    int hint_system;

    int is_mounted;
    char *mount_point;         /* real UDisks mount point, NULL if unmounted */
    int is_loop;
    char *loop_backing_file;   /* set only for loop devices (ISO mounts) */

    char *drive_vendor, *drive_model, *drive_serial, *connection_bus;
    int removable, ejectable, can_power_off;

    int is_external;            /* per EXTERNAL_BUS_LIST / Removable, see device.c */
    int is_protected;           /* HintSystem or mounted under a PROTECTED_MOUNT_PREFIXES path -- never offer unmount/eject/poweroff */

    int usage_valid;
    unsigned long long used_bytes, free_bytes, total_bytes;
    int percent_used, percent_free;

    char display_name[256];
    char resolved_color[16];

    char *symlink_path;         /* configured custom-mount-point symlink target, or NULL -- see state_file.h */
} Device;

typedef struct {
    Device *items;
    int count;
} DeviceList;

/* Full rebuild: queries UDisks, applies all filters/overrides, and
 * runs an initial statvfs() usage check on every mounted device.
 * Returns the new count (0 is valid -- nothing plugged in), or -1 if
 * UDisks itself couldn't be reached (treat as "no devices", not a
 * crash -- the daemon should keep polling, UDisks may just not be up
 * yet). Frees anything previously in *list first. */
int device_list_build(DeviceList *list);

/* Re-runs statvfs() on every already-mounted device in `list` without
 * touching D-Bus at all -- this is the cheap path used for the
 * periodic USAGE_CHECK_INTERVAL_SEC refresh and for manual Reload. */
void device_list_refresh_usage(DeviceList *list);

void device_list_free(DeviceList *list);

/* Finds a device by object path (exact), then device node (exact),
 * then UUID (exact, case-insensitive) -- in that order. Returns NULL
 * if none match. Used to resolve the -i/--id CLI argument. */
Device *device_list_find(DeviceList *list, const char *id);

/* Substring, case-insensitive match against a device's UUID, label,
 * device node, then drive serial (first field that matches wins).
 * Used for DEVICE_OVERRIDES / HIDDEN_DEVICES / AUTOMOUNT_OVERRIDES. */
int device_matches_pattern(const Device *d, const char *pattern);

/* Effective icon for `d`, given its current mount state. Applies the
 * full fallback chain described in config.h (per-device override ->
 * kind guess -> generic mounted/unmounted -> ICON_DEVICE_GENERIC).
 * Returns a pointer into either config.h string literals or a static
 * per-call buffer -- copy it if you need it to outlive the next call. */
const char *device_effective_icon(const Device *d);

/* Human-readable size, e.g. "12.3G". `out` must be at least 16 bytes. */
void device_format_size(unsigned long long bytes, char *out, size_t outlen);

/* Effective automount decision for `d` (AUTOMOUNT_OVERRIDES, falling
 * back to AUTOMOUNT_GLOBAL_DEFAULT). */
int device_should_automount(const Device *d);

#endif /* DEVICE_H */
