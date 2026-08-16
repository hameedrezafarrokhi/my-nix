/*
 * udisks.c
 *
 * Raw libdbus plumbing for org.freedesktop.UDisks2, on the SYSTEM
 * bus (unlike kdeconnect, which lives on the session bus). No glib,
 * no gdbus -- same reasoning as the kdeconnect module: fewer shared
 * libraries mapped in, smaller idle RSS, and one less runtime to
 * reason about.
 *
 * The trickiest part here is GetManagedObjects()'s reply type,
 * a{oa{sa{sv}}} -- a dict of object paths, each holding a dict of
 * interface names, each holding a dict of property-name -> variant.
 * The variant_get_* helpers below unwrap one property's variant at a
 * time; parse_block_object()/parse_drive_object() walk the two
 * outer dicts and call into those as needed.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <dbus/dbus.h>

#include "udisks.h"
#include "config.h"

static DBusConnection *g_conn = NULL;

DBusConnection *ud_conn(void) {
    if (!g_conn) {
        DBusError err;
        dbus_error_init(&err);
        g_conn = dbus_bus_get(DBUS_BUS_SYSTEM, &err);
        if (dbus_error_is_set(&err) || !g_conn) {
            fprintf(stderr, "polybar-udisks: system D-Bus connection failed: %s\n",
                    dbus_error_is_set(&err) ? err.message : "unknown error");
            dbus_error_free(&err);
            exit(1);
        }
    }
    return g_conn;
}

/* ------------------------------------------------------------------ */
/* variant readers                                                     */
/* ------------------------------------------------------------------ */

/* `iter` must be positioned at a VARIANT. Returns a malloc'd string
 * for STRING/OBJECT_PATH variants, or NULL for anything else. */
static char *variant_get_string(DBusMessageIter *iter) {
    if (dbus_message_iter_get_arg_type(iter) != DBUS_TYPE_VARIANT) return NULL;
    DBusMessageIter v;
    dbus_message_iter_recurse(iter, &v);
    int t = dbus_message_iter_get_arg_type(&v);
    if (t == DBUS_TYPE_STRING || t == DBUS_TYPE_OBJECT_PATH) {
        const char *s = NULL;
        dbus_message_iter_get_basic(&v, &s);
        return s ? strdup(s) : NULL;
    }
    return NULL;
}

static int variant_get_bool(DBusMessageIter *iter, int *out) {
    if (dbus_message_iter_get_arg_type(iter) != DBUS_TYPE_VARIANT) return 0;
    DBusMessageIter v;
    dbus_message_iter_recurse(iter, &v);
    if (dbus_message_iter_get_arg_type(&v) != DBUS_TYPE_BOOLEAN) return 0;
    dbus_bool_t b = FALSE;
    dbus_message_iter_get_basic(&v, &b);
    *out = b ? 1 : 0;
    return 1;
}

static int variant_get_u64(DBusMessageIter *iter, unsigned long long *out) {
    if (dbus_message_iter_get_arg_type(iter) != DBUS_TYPE_VARIANT) return 0;
    DBusMessageIter v;
    dbus_message_iter_recurse(iter, &v);
    int t = dbus_message_iter_get_arg_type(&v);
    if (t == DBUS_TYPE_UINT64) {
        dbus_uint64_t u = 0;
        dbus_message_iter_get_basic(&v, &u);
        *out = (unsigned long long)u;
        return 1;
    }
    if (t == DBUS_TYPE_INT64) {
        dbus_int64_t i = 0;
        dbus_message_iter_get_basic(&v, &i);
        *out = (unsigned long long)i;
        return 1;
    }
    if (t == DBUS_TYPE_UINT32) {
        dbus_uint32_t u = 0;
        dbus_message_iter_get_basic(&v, &u);
        *out = (unsigned long long)u;
        return 1;
    }
    return 0;
}

/* Reads an "ay" (byte array) variant as a NUL-terminated C string --
 * UDisks' convention for Device/PreferredDevice/Symlinks/MountPoints
 * entries: a plain path encoded as bytes including the trailing NUL. */
static char *variant_get_bytestring(DBusMessageIter *iter) {
    if (dbus_message_iter_get_arg_type(iter) != DBUS_TYPE_VARIANT) return NULL;
    DBusMessageIter v;
    dbus_message_iter_recurse(iter, &v);
    if (dbus_message_iter_get_arg_type(&v) != DBUS_TYPE_ARRAY) return NULL;

    DBusMessageIter arr;
    dbus_message_iter_recurse(&v, &arr);

    char *buf = malloc(4096);
    if (!buf) return NULL;
    size_t len = 0;
    while (dbus_message_iter_get_arg_type(&arr) == DBUS_TYPE_BYTE) {
        unsigned char byte = 0;
        dbus_message_iter_get_basic(&arr, &byte);
        if (byte == 0) break;
        if (len + 1 < 4096) buf[len++] = (char)byte;
        dbus_message_iter_next(&arr);
    }
    buf[len] = '\0';
    return buf;
}

/* Reads an "aay" (array of byte-array-strings) variant, e.g.
 * Filesystem.MountPoints. Sets *out_count and returns a malloc'd
 * array of malloc'd strings (may be a 0-length array, never NULL on
 * a genuine empty list -- NULL only means "not an aay at all"). */
static char **variant_get_bytestring_array(DBusMessageIter *iter, int *out_count) {
    *out_count = 0;
    if (dbus_message_iter_get_arg_type(iter) != DBUS_TYPE_VARIANT) return NULL;
    DBusMessageIter v;
    dbus_message_iter_recurse(iter, &v);
    if (dbus_message_iter_get_arg_type(&v) != DBUS_TYPE_ARRAY) return NULL;

    DBusMessageIter outer;
    dbus_message_iter_recurse(&v, &outer);

    char **result = NULL;
    int count = 0;
    while (dbus_message_iter_get_arg_type(&outer) == DBUS_TYPE_ARRAY) {
        DBusMessageIter inner;
        dbus_message_iter_recurse(&outer, &inner);
        char *buf = malloc(4096);
        size_t len = 0;
        if (buf) {
            while (dbus_message_iter_get_arg_type(&inner) == DBUS_TYPE_BYTE) {
                unsigned char byte = 0;
                dbus_message_iter_get_basic(&inner, &byte);
                if (byte == 0) break;
                if (len + 1 < 4096) buf[len++] = (char)byte;
                dbus_message_iter_next(&inner);
            }
            buf[len] = '\0';
        }
        result = realloc(result, sizeof(char *) * (count + 1));
        result[count++] = buf;
        dbus_message_iter_next(&outer);
    }
    *out_count = count;
    return result;
}

/* ------------------------------------------------------------------ */
/* GetManagedObjects parsing                                           */
/* ------------------------------------------------------------------ */

/* Temporary per-drive-object record, joined onto blocks afterward. */
typedef struct {
    char *path;
    char *vendor, *model, *serial, *connection_bus;
    int removable, ejectable, can_power_off, media_available, optical;
} DriveRec;

static void parse_block_props(DBusMessageIter *props_iter, UdisksRawObject *o) {
    DBusMessageIter props;
    dbus_message_iter_recurse(props_iter, &props);
    while (dbus_message_iter_get_arg_type(&props) == DBUS_TYPE_DICT_ENTRY) {
        DBusMessageIter entry;
        dbus_message_iter_recurse(&props, &entry);
        const char *key = NULL;
        dbus_message_iter_get_basic(&entry, &key);
        dbus_message_iter_next(&entry);

        if (!strcmp(key, "Device")) {
            free(o->device_node);
            o->device_node = variant_get_bytestring(&entry);
        } else if (!strcmp(key, "IdLabel")) {
            free(o->id_label);
            o->id_label = variant_get_string(&entry);
        } else if (!strcmp(key, "IdUUID")) {
            free(o->id_uuid);
            o->id_uuid = variant_get_string(&entry);
        } else if (!strcmp(key, "IdType")) {
            free(o->id_type);
            o->id_type = variant_get_string(&entry);
        } else if (!strcmp(key, "IdUsage")) {
            free(o->id_usage);
            o->id_usage = variant_get_string(&entry);
        } else if (!strcmp(key, "Size")) {
            variant_get_u64(&entry, &o->size);
        } else if (!strcmp(key, "ReadOnly")) {
            variant_get_bool(&entry, &o->read_only);
        } else if (!strcmp(key, "HintSystem")) {
            variant_get_bool(&entry, &o->hint_system);
        } else if (!strcmp(key, "HintIgnore")) {
            variant_get_bool(&entry, &o->hint_ignore);
        } else if (!strcmp(key, "Drive")) {
            char *dp = variant_get_string(&entry);
            if (dp) {
                if (strcmp(dp, "/") != 0) {
                    free(o->drive_path);
                    o->drive_path = dp;
                } else {
                    free(dp);
                }
            }
        } else if (!strcmp(key, "CryptoBackingDevice")) {
            char *cp = variant_get_string(&entry);
            if (cp) {
                if (strcmp(cp, "/") != 0) {
                    free(o->crypto_backing_device);
                    o->crypto_backing_device = cp;
                } else {
                    free(cp);
                }
            }
        }
        dbus_message_iter_next(&props);
    }
}

static void parse_filesystem_props(DBusMessageIter *props_iter, UdisksRawObject *o) {
    DBusMessageIter props;
    dbus_message_iter_recurse(props_iter, &props);
    while (dbus_message_iter_get_arg_type(&props) == DBUS_TYPE_DICT_ENTRY) {
        DBusMessageIter entry;
        dbus_message_iter_recurse(&props, &entry);
        const char *key = NULL;
        dbus_message_iter_get_basic(&entry, &key);
        dbus_message_iter_next(&entry);

        if (!strcmp(key, "MountPoints")) {
            int n = 0;
            char **mp = variant_get_bytestring_array(&entry, &n);
            for (int i = 0; i < o->n_mount_points; i++) free(o->mount_points[i]);
            free(o->mount_points);
            o->mount_points = mp;
            o->n_mount_points = n;
        }
        dbus_message_iter_next(&props);
    }
}

static void parse_partition_props(DBusMessageIter *props_iter, UdisksRawObject *o) {
    DBusMessageIter props;
    dbus_message_iter_recurse(props_iter, &props);
    while (dbus_message_iter_get_arg_type(&props) == DBUS_TYPE_DICT_ENTRY) {
        DBusMessageIter entry;
        dbus_message_iter_recurse(&props, &entry);
        const char *key = NULL;
        dbus_message_iter_get_basic(&entry, &key);
        dbus_message_iter_next(&entry);
        if (!strcmp(key, "Table")) {
            char *tp = variant_get_string(&entry);
            if (tp) {
                if (strcmp(tp, "/") != 0) {
                    free(o->partition_table_path);
                    o->partition_table_path = tp;
                } else {
                    free(tp);
                }
            }
        }
        dbus_message_iter_next(&props);
    }
}

static void parse_loop_props(DBusMessageIter *props_iter, UdisksRawObject *o) {
    DBusMessageIter props;
    dbus_message_iter_recurse(props_iter, &props);
    while (dbus_message_iter_get_arg_type(&props) == DBUS_TYPE_DICT_ENTRY) {
        DBusMessageIter entry;
        dbus_message_iter_recurse(&props, &entry);
        const char *key = NULL;
        dbus_message_iter_get_basic(&entry, &key);
        dbus_message_iter_next(&entry);
        if (!strcmp(key, "BackingFile")) {
            free(o->loop_backing_file);
            o->loop_backing_file = variant_get_bytestring(&entry);
        }
        dbus_message_iter_next(&props);
    }
}

static void parse_drive_props(DBusMessageIter *props_iter, DriveRec *d) {
    DBusMessageIter props;
    dbus_message_iter_recurse(props_iter, &props);
    while (dbus_message_iter_get_arg_type(&props) == DBUS_TYPE_DICT_ENTRY) {
        DBusMessageIter entry;
        dbus_message_iter_recurse(&props, &entry);
        const char *key = NULL;
        dbus_message_iter_get_basic(&entry, &key);
        dbus_message_iter_next(&entry);

        if (!strcmp(key, "Vendor")) { free(d->vendor); d->vendor = variant_get_string(&entry); }
        else if (!strcmp(key, "Model")) { free(d->model); d->model = variant_get_string(&entry); }
        else if (!strcmp(key, "Serial")) { free(d->serial); d->serial = variant_get_string(&entry); }
        else if (!strcmp(key, "ConnectionBus")) { free(d->connection_bus); d->connection_bus = variant_get_string(&entry); }
        else if (!strcmp(key, "Removable")) variant_get_bool(&entry, &d->removable);
        else if (!strcmp(key, "Ejectable")) variant_get_bool(&entry, &d->ejectable);
        else if (!strcmp(key, "CanPowerOff")) variant_get_bool(&entry, &d->can_power_off);
        else if (!strcmp(key, "MediaAvailable")) variant_get_bool(&entry, &d->media_available);
        else if (!strcmp(key, "Optical")) variant_get_bool(&entry, &d->optical);

        dbus_message_iter_next(&props);
    }
}

int udisks_get_all(UdisksRawObject **out_objects) {
    *out_objects = NULL;

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, UDISKS_ROOT_PATH, "org.freedesktop.DBus.ObjectManager", "GetManagedObjects");
    if (!msg) return -1;

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return -1;
    }
    if (!reply) return -1;

    DBusMessageIter args;
    if (!dbus_message_iter_init(reply, &args) || dbus_message_iter_get_arg_type(&args) != DBUS_TYPE_ARRAY) {
        dbus_message_unref(reply);
        return -1;
    }

    UdisksRawObject *blocks = NULL;
    int n_blocks = 0;
    DriveRec *drives = NULL;
    int n_drives = 0;

    DBusMessageIter objects;
    dbus_message_iter_recurse(&args, &objects);
    while (dbus_message_iter_get_arg_type(&objects) == DBUS_TYPE_DICT_ENTRY) {
        DBusMessageIter obj_entry;
        dbus_message_iter_recurse(&objects, &obj_entry);

        const char *object_path = NULL;
        dbus_message_iter_get_basic(&obj_entry, &object_path);
        dbus_message_iter_next(&obj_entry); /* now at a{sa{sv}} */

        int is_drive = 0;
        UdisksRawObject block;
        memset(&block, 0, sizeof(block));
        DriveRec drive;
        memset(&drive, 0, sizeof(drive));

        DBusMessageIter ifaces;
        dbus_message_iter_recurse(&obj_entry, &ifaces);
        while (dbus_message_iter_get_arg_type(&ifaces) == DBUS_TYPE_DICT_ENTRY) {
            DBusMessageIter iface_entry;
            dbus_message_iter_recurse(&ifaces, &iface_entry);
            const char *iface_name = NULL;
            dbus_message_iter_get_basic(&iface_entry, &iface_name);
            dbus_message_iter_next(&iface_entry); /* now at a{sv} props */

            if (!strcmp(iface_name, UDISKS_IFACE_BLOCK)) {
                parse_block_props(&iface_entry, &block);
                block.path = strdup(object_path);
            } else if (!strcmp(iface_name, UDISKS_IFACE_FILESYSTEM)) {
                block.has_filesystem = 1;
                parse_filesystem_props(&iface_entry, &block);
            } else if (!strcmp(iface_name, UDISKS_IFACE_PARTITION)) {
                block.has_partition = 1;
                parse_partition_props(&iface_entry, &block);
            } else if (!strcmp(iface_name, UDISKS_IFACE_LOOP)) {
                block.has_loop = 1;
                parse_loop_props(&iface_entry, &block);
            } else if (!strcmp(iface_name, UDISKS_IFACE_ENCRYPTED)) {
                block.has_encrypted = 1;
            } else if (!strcmp(iface_name, UDISKS_IFACE_DRIVE)) {
                is_drive = 1;
                drive.path = strdup(object_path);
                parse_drive_props(&iface_entry, &drive);
            }

            dbus_message_iter_next(&ifaces);
        }

        if (block.path) {
            blocks = realloc(blocks, sizeof(UdisksRawObject) * (n_blocks + 1));
            blocks[n_blocks++] = block;
        } else {
            free(block.device_node); free(block.id_label); free(block.id_uuid);
            free(block.id_type); free(block.id_usage); free(block.drive_path);
            free(block.loop_backing_file); free(block.crypto_backing_device); free(block.partition_table_path);
            for (int i = 0; i < block.n_mount_points; i++) free(block.mount_points[i]);
            free(block.mount_points);
        }

        if (is_drive) {
            drives = realloc(drives, sizeof(DriveRec) * (n_drives + 1));
            drives[n_drives++] = drive;
        } else {
            free(drive.path); free(drive.vendor); free(drive.model);
            free(drive.serial); free(drive.connection_bus);
        }

        dbus_message_iter_next(&objects);
    }
    dbus_message_unref(reply);

    /* Join drive info onto each block that references one */
    for (int i = 0; i < n_blocks; i++) {
        if (!blocks[i].drive_path) continue;
        for (int j = 0; j < n_drives; j++) {
            if (drives[j].path && !strcmp(drives[j].path, blocks[i].drive_path)) {
                blocks[i].drive_vendor = drives[j].vendor ? strdup(drives[j].vendor) : NULL;
                blocks[i].drive_model  = drives[j].model  ? strdup(drives[j].model)  : NULL;
                blocks[i].drive_serial = drives[j].serial ? strdup(drives[j].serial) : NULL;
                blocks[i].connection_bus = drives[j].connection_bus ? strdup(drives[j].connection_bus) : NULL;
                blocks[i].drive_removable = drives[j].removable;
                blocks[i].drive_ejectable = drives[j].ejectable;
                blocks[i].drive_can_power_off = drives[j].can_power_off;
                blocks[i].drive_media_available = drives[j].media_available;
                blocks[i].drive_optical = drives[j].optical;
                break;
            }
        }
    }

    for (int j = 0; j < n_drives; j++) {
        free(drives[j].path); free(drives[j].vendor); free(drives[j].model);
        free(drives[j].serial); free(drives[j].connection_bus);
    }
    free(drives);

    *out_objects = blocks;
    return n_blocks;
}

void udisks_free_raw_objects(UdisksRawObject *objects, int count) {
    for (int i = 0; i < count; i++) {
        free(objects[i].path);
        free(objects[i].drive_path);
        free(objects[i].device_node);
        free(objects[i].id_label);
        free(objects[i].id_uuid);
        free(objects[i].id_type);
        free(objects[i].id_usage);
        free(objects[i].loop_backing_file);
        free(objects[i].crypto_backing_device);
        free(objects[i].partition_table_path);
        for (int j = 0; j < objects[i].n_mount_points; j++) free(objects[i].mount_points[j]);
        free(objects[i].mount_points);
        free(objects[i].drive_vendor);
        free(objects[i].drive_model);
        free(objects[i].drive_serial);
        free(objects[i].connection_bus);
    }
    free(objects);
}

/* ------------------------------------------------------------------ */
/* actions                                                             */
/* ------------------------------------------------------------------ */

static void open_empty_options(DBusMessageIter *args, DBusMessageIter *dict) {
    dbus_message_iter_open_container(args, DBUS_TYPE_ARRAY, "{sv}", dict);
}

static void append_bool_option(DBusMessageIter *dict, const char *key, int value) {
    DBusMessageIter entry, variant;
    dbus_message_iter_open_container(dict, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &key);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, "b", &variant);
    dbus_bool_t b = value ? TRUE : FALSE;
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_BOOLEAN, &b);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(dict, &entry);
}

static char *extract_error_message(DBusError *err, DBusMessage *reply) {
    if (dbus_error_is_set(err)) {
        char *m = strdup(err->message ? err->message : "unknown D-Bus error");
        dbus_error_free(err);
        return m;
    }
    (void)reply;
    return strdup("request failed");
}

int udisks_mount(const char *block_object_path, char **out_mount_point, char **out_error) {
    *out_mount_point = NULL;
    if (out_error) *out_error = NULL;

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, block_object_path, UDISKS_IFACE_FILESYSTEM, "Mount");
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    open_empty_options(&args, &dict);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }

    DBusMessageIter reply_args;
    if (dbus_message_iter_init(reply, &reply_args) &&
        dbus_message_iter_get_arg_type(&reply_args) == DBUS_TYPE_STRING) {
        const char *mp = NULL;
        dbus_message_iter_get_basic(&reply_args, &mp);
        if (mp) *out_mount_point = strdup(mp);
    }
    dbus_message_unref(reply);
    return 1;
}

int udisks_unmount(const char *block_object_path, int force, char **out_error) {
    if (out_error) *out_error = NULL;

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, block_object_path, UDISKS_IFACE_FILESYSTEM, "Unmount");
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    open_empty_options(&args, &dict);
    if (force) append_bool_option(&dict, "force", 1);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }
    dbus_message_unref(reply);
    return 1;
}

static int drive_action(const char *drive_object_path, const char *method, char **out_error) {
    if (out_error) *out_error = NULL;

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, drive_object_path, UDISKS_IFACE_DRIVE, method);
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    open_empty_options(&args, &dict);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }
    dbus_message_unref(reply);
    return 1;
}

int udisks_eject(const char *drive_object_path, char **out_error) {
    return drive_action(drive_object_path, "Eject", out_error);
}

int udisks_power_off(const char *drive_object_path, char **out_error) {
    return drive_action(drive_object_path, "PowerOff", out_error);
}

int udisks_loop_mount_file(const char *file_path, char **out_block_path,
                            char **out_mount_point, char **out_error) {
    *out_block_path = NULL;
    *out_mount_point = NULL;
    if (out_error) *out_error = NULL;

    int fd = open(file_path, O_RDONLY);
    if (fd < 0) {
        if (out_error) {
            char buf[512];
            snprintf(buf, sizeof(buf), "could not open %s: %s", file_path, strerror(errno));
            *out_error = strdup(buf);
        }
        return 0;
    }

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, UDISKS_MANAGER_PATH, UDISKS_IFACE_MANAGER, "LoopSetup");
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_UNIX_FD, &fd);
    open_empty_options(&args, &dict);
    append_bool_option(&dict, "read-only", 1);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);
    close(fd);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }

    DBusMessageIter reply_args;
    char *loop_path = NULL;
    if (dbus_message_iter_init(reply, &reply_args) &&
        dbus_message_iter_get_arg_type(&reply_args) == DBUS_TYPE_OBJECT_PATH) {
        const char *p = NULL;
        dbus_message_iter_get_basic(&reply_args, &p);
        if (p) loop_path = strdup(p);
    }
    dbus_message_unref(reply);

    if (!loop_path) {
        if (out_error) *out_error = strdup("LoopSetup did not return an object path");
        return 0;
    }

    /* The loop device -- or, for hybrid/bootable ISOs carrying an
     * MBR/GPT partition table (common for Linux distro install media
     * meant to be dd'd to USB and booted), whichever of its
     * partitions actually holds the filesystem -- needs a moment for
     * UDisks to probe and expose before Mount() will work. Poll both
     * possibilities for a few seconds; which one applies isn't
     * knowable up front. */
    char *mount_err = NULL;
    for (int attempt = 0; attempt < 15; attempt++) {
        UdisksRawObject *raw = NULL;
        int n_raw = udisks_get_all(&raw);

        char *candidate = NULL;      /* NULL, loop_path itself, or a strdup'd partition path */
        int candidate_is_loop = 0;

        for (int i = 0; i < n_raw; i++) {
            if (!strcmp(raw[i].path, loop_path) && raw[i].has_filesystem) {
                candidate = loop_path;
                candidate_is_loop = 1;
                break;
            }
        }
        if (!candidate) {
            for (int i = 0; i < n_raw; i++) {
                if (raw[i].partition_table_path && !strcmp(raw[i].partition_table_path, loop_path) &&
                    raw[i].has_filesystem) {
                    candidate = strdup(raw[i].path);
                    break;
                }
            }
        }
        udisks_free_raw_objects(raw, n_raw > 0 ? n_raw : 0);

        if (candidate) {
            free(mount_err); mount_err = NULL;
            int ok = udisks_mount(candidate, out_mount_point, &mount_err);
            if (!candidate_is_loop) free(candidate);
            if (ok) {
                free(mount_err);
                *out_block_path = loop_path;
                return 1;
            }
        }
        free(mount_err); mount_err = NULL;
        usleep(300000);
    }

    if (out_error) *out_error = strdup(
        "attached the ISO as a loop device, but UDisks never exposed a mountable filesystem on it "
        "or any of its partitions -- is this a valid ISO9660/UDF image?");
    *out_block_path = loop_path;
    return 0;
}

int udisks_loop_delete(const char *loop_block_object_path, char **out_error) {
    if (out_error) *out_error = NULL;

    /* Unmount the loop device itself (if mounted directly) and any
     * partition of it (for hybrid/bootable ISOs where the filesystem
     * lives on a partition instead -- see udisks_loop_mount_file)
     * before detaching, or Loop.Delete will fail with "busy". */
    UdisksRawObject *raw = NULL;
    int n_raw = udisks_get_all(&raw);
    for (int i = 0; i < n_raw; i++) {
        int is_self = !strcmp(raw[i].path, loop_block_object_path);
        int is_child = raw[i].partition_table_path && !strcmp(raw[i].partition_table_path, loop_block_object_path);
        if ((is_self || is_child) && raw[i].n_mount_points > 0) {
            char *unmount_err = NULL;
            udisks_unmount(raw[i].path, 0, &unmount_err);
            free(unmount_err);
        }
    }
    udisks_free_raw_objects(raw, n_raw > 0 ? n_raw : 0);

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, loop_block_object_path, UDISKS_IFACE_LOOP, "Delete");
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    open_empty_options(&args, &dict);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }
    dbus_message_unref(reply);
    return 1;
}

/* ------------------------------------------------------------------ */
/* encrypted (LUKS) containers                                          */
/* ------------------------------------------------------------------ */

int udisks_unlock(const char *container_object_path, const char *passphrase,
                   char **out_cleartext_path, char **out_error) {
    *out_cleartext_path = NULL;
    if (out_error) *out_error = NULL;

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, container_object_path, UDISKS_IFACE_ENCRYPTED, "Unlock");
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    const char *pass = passphrase ? passphrase : "";
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &pass);
    open_empty_options(&args, &dict);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }

    DBusMessageIter reply_args;
    if (dbus_message_iter_init(reply, &reply_args) &&
        dbus_message_iter_get_arg_type(&reply_args) == DBUS_TYPE_OBJECT_PATH) {
        const char *p = NULL;
        dbus_message_iter_get_basic(&reply_args, &p);
        if (p) *out_cleartext_path = strdup(p);
    }
    dbus_message_unref(reply);
    return 1;
}

int udisks_lock(const char *container_object_path, char **out_error) {
    if (out_error) *out_error = NULL;

    DBusMessage *msg = dbus_message_new_method_call(
        UDISKS_SERVICE, container_object_path, UDISKS_IFACE_ENCRYPTED, "Lock");
    DBusMessageIter args, dict;
    dbus_message_iter_init_append(msg, &args);
    open_empty_options(&args, &dict);
    dbus_message_iter_close_container(&args, &dict);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(ud_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (!reply) {
        if (out_error) *out_error = extract_error_message(&err, NULL);
        else dbus_error_free(&err);
        return 0;
    }
    dbus_message_unref(reply);
    return 1;
}

/* ------------------------------------------------------------------ */
/* signals                                                             */
/* ------------------------------------------------------------------ */

void udisks_subscribe_signals(void) {
    DBusError err;
    dbus_error_init(&err);
    dbus_bus_add_match(ud_conn(),
        "type='signal',sender='" UDISKS_SERVICE "',path_namespace='" UDISKS_ROOT_PATH "'",
        &err);
    if (dbus_error_is_set(&err)) {
        fprintf(stderr, "polybar-udisks: failed to subscribe to UDisks2 signals: %s\n", err.message);
        dbus_error_free(&err);
    }
    dbus_connection_flush(ud_conn());
}

int udisks_message_is_relevant_signal(DBusMessage *msg) {
    if (dbus_message_get_type(msg) != DBUS_MESSAGE_TYPE_SIGNAL) return 0;
    if (dbus_message_is_signal(msg, "org.freedesktop.DBus.ObjectManager", "InterfacesAdded")) return 1;
    if (dbus_message_is_signal(msg, "org.freedesktop.DBus.ObjectManager", "InterfacesRemoved")) return 1;
    if (dbus_message_is_signal(msg, "org.freedesktop.DBus.Properties", "PropertiesChanged")) return 1;
    return 0;
}
