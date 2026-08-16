#ifndef UDISKS_H
#define UDISKS_H

#include <dbus/dbus.h>

/*
 * udisks.h
 *
 * Thin, purpose-built wrapper around the org.freedesktop.UDisks2 D-Bus
 * API (raw libdbus, same low-level style as the kdeconnect module's
 * dbus_client.c -- no glib/gio, no gdbus, keeps the binary and its
 * idle footprint tiny).
 *
 * This layer only knows about UDisks concepts (objects, interfaces,
 * properties, Mount/Unmount/Eject/PowerOff/loop devices). It doesn't
 * know about filtering, icons, color ramps, or menus -- see device.h
 * for the layer that turns this into what the rest of the program
 * actually works with.
 */

#define UDISKS_SERVICE     "org.freedesktop.UDisks2"
#define UDISKS_MANAGER_PATH "/org/freedesktop/UDisks2/Manager"
#define UDISKS_ROOT_PATH    "/org/freedesktop/UDisks2"

#define UDISKS_IFACE_BLOCK      "org.freedesktop.UDisks2.Block"
#define UDISKS_IFACE_FILESYSTEM "org.freedesktop.UDisks2.Filesystem"
#define UDISKS_IFACE_DRIVE      "org.freedesktop.UDisks2.Drive"
#define UDISKS_IFACE_PARTITION  "org.freedesktop.UDisks2.Partition"
#define UDISKS_IFACE_LOOP       "org.freedesktop.UDisks2.Loop"
#define UDISKS_IFACE_ENCRYPTED  "org.freedesktop.UDisks2.Encrypted"
#define UDISKS_IFACE_MANAGER    "org.freedesktop.UDisks2.Manager"

/* One row per UDisks object that has a Block interface (i.e. every
 * block device UDisks knows about -- whole disks and partitions
 * alike). Drive-level fields are already joined in from the object's
 * Drive= property for convenience, so callers don't have to do a
 * second lookup. All strings are malloc'd (or NULL); free with
 * udisks_free_raw_objects(). */
typedef struct {
    char *path;              /* e.g. /org/freedesktop/UDisks2/block_devices/sdb1 */
    char *drive_path;        /* e.g. /org/freedesktop/UDisks2/drives/Kingston_..., or NULL */

    int has_filesystem;      /* object implements the Filesystem interface */
    int has_partition;
    int has_loop;
    int has_encrypted;

    char *device_node;       /* /dev/sdb1 */
    char *id_label;          /* may be NULL/empty */
    char *id_uuid;
    char *id_type;            /* "ext4", "vfat", "ntfs", "swap", "", ... */
    char *id_usage;           /* "filesystem", "crypto", "other", "", ... */
    unsigned long long size;  /* bytes, from Block.Size */
    int read_only;
    int hint_system;
    int hint_ignore;

    char **mount_points;      /* NULL if unmounted or no Filesystem iface */
    int n_mount_points;

    char *loop_backing_file;  /* set only if has_loop */
    char *crypto_backing_device; /* set only on a cleartext device unlocked from a LUKS container -- the container's object path */

    /* Joined in from the Drive object referenced by drive_path, if any */
    char *drive_vendor;
    char *drive_model;
    char *drive_serial;
    char *connection_bus;     /* "usb", "ata", "sdio", "scsi", "nvme", ... */
    int drive_removable;
    int drive_ejectable;
    int drive_can_power_off;
    int drive_media_available;
    int drive_optical;
} UdisksRawObject;

/* Returns the shared session-bus... no -- UDisks lives on the SYSTEM
 * bus. Exits the process with an error message on failure, same
 * fail-fast convention as the kdeconnect module's kdc_conn(). */
DBusConnection *ud_conn(void);

/* Calls org.freedesktop.DBus.ObjectManager.GetManagedObjects() on
 * UDisks' root object and flattens the result into an array of
 * UdisksRawObject, one per object with a Block interface. Returns the
 * count, or -1 on D-Bus failure (daemon not running, etc -- caller
 * should treat that the same as "zero devices", not crash). */
int udisks_get_all(UdisksRawObject **out_objects);
void udisks_free_raw_objects(UdisksRawObject *objects, int count);

/* Mount/Unmount/Eject/PowerOff. On success returns 1; on failure
 * returns 0 and *out_error is set to a malloc'd human-readable string
 * (caller frees). *out_mount_point is malloc'd on a successful mount. */
int udisks_mount(const char *block_object_path, char **out_mount_point, char **out_error);
int udisks_unmount(const char *block_object_path, int force, char **out_error);
int udisks_eject(const char *drive_object_path, char **out_error);
int udisks_power_off(const char *drive_object_path, char **out_error);

/* Attaches a regular file as a loop device (for "Mount ISO"), then
 * mounts it read-only. On success *out_block_path is the new loop
 * device's UDisks object path (malloc'd) and *out_mount_point its
 * mount path (malloc'd). */
int udisks_loop_mount_file(const char *file_path, char **out_block_path,
                            char **out_mount_point, char **out_error);

/* Unmounts (if needed) and detaches a loop device entirely -- used
 * for "Detach ISO". */
int udisks_loop_delete(const char *loop_block_object_path, char **out_error);

/* Unlocks a LUKS (or other UDisks-supported) encrypted container.
 * On success, *out_cleartext_path is the new cleartext block device's
 * UDisks object path (malloc'd) -- it will shortly also show up via
 * InterfacesAdded, but returning it directly here avoids a race where
 * the caller needs it before the next signal-driven rebuild happens. */
int udisks_unlock(const char *container_object_path, const char *passphrase,
                   char **out_cleartext_path, char **out_error);

/* Locks a container back up. The cleartext device must already be
 * unmounted -- callers should unmount it first (udisks_unmount on the
 * cleartext object path) and treat a failure here as "still open
 * somewhere", not retry blindly. */
int udisks_lock(const char *container_object_path, char **out_error);

/* Adds the one match rule that catches everything the daemon cares
 * about (ObjectManager add/remove + PropertiesChanged for every
 * object under the UDisks root) and flushes it. Call once, before
 * entering the poll() loop. */
void udisks_subscribe_signals(void);

/* True if `msg` is one of the signals udisks_subscribe_signals()
 * matched (InterfacesAdded, InterfacesRemoved, or PropertiesChanged
 * scoped to org.freedesktop.UDisks2.*). Used by daemon.c to decide
 * whether an incoming message should trigger a re-render. */
int udisks_message_is_relevant_signal(DBusMessage *msg);

#endif /* UDISKS_H */
