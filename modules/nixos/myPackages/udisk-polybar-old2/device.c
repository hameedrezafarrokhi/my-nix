#define _GNU_SOURCE /* strcasestr */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/statvfs.h>

#include "device.h"
#include "udisks.h"
#include "state_file.h"
#include "config.h"

/* ------------------------------------------------------------------ */
/* matching                                                            */
/* ------------------------------------------------------------------ */

static int field_has(const char *pattern, const char *field) {
    if (!pattern || !pattern[0] || !field || !field[0]) return 0;
    return strcasestr(field, pattern) != NULL;
}

int device_matches_pattern(const Device *d, const char *pattern) {
    if (!pattern || !pattern[0]) return 0;
    if (field_has(pattern, d->uuid)) return 1;
    if (field_has(pattern, d->label)) return 1;
    if (field_has(pattern, d->device_node)) return 1;
    if (field_has(pattern, d->drive_serial)) return 1;
    return 0;
}

static int raw_matches_pattern(const UdisksRawObject *o, const char *pattern) {
    if (!pattern || !pattern[0]) return 0;
    if (field_has(pattern, o->id_uuid)) return 1;
    if (field_has(pattern, o->id_label)) return 1;
    if (field_has(pattern, o->device_node)) return 1;
    if (field_has(pattern, o->drive_serial)) return 1;
    return 0;
}

static const DeviceOverride *find_override(const Device *d) {
    for (int i = 0; DEVICE_OVERRIDES[i].match; i++) {
        if (device_matches_pattern(d, DEVICE_OVERRIDES[i].match)) return &DEVICE_OVERRIDES[i];
    }
    return NULL;
}

int device_should_automount(const Device *d) {
    for (int i = 0; AUTOMOUNT_OVERRIDES[i].match; i++) {
        if (device_matches_pattern(d, AUTOMOUNT_OVERRIDES[i].match)) return AUTOMOUNT_OVERRIDES[i].automount;
    }
    return AUTOMOUNT_GLOBAL_DEFAULT;
}

int device_should_remember_passphrase(const Device *d) {
    for (int i = 0; PASSPHRASE_CACHE_OVERRIDES[i].match; i++) {
        if (device_matches_pattern(d, PASSPHRASE_CACHE_OVERRIDES[i].match)) return PASSPHRASE_CACHE_OVERRIDES[i].remember;
    }
    return REMEMBER_PASSPHRASE_DEFAULT;
}

/* ------------------------------------------------------------------ */
/* formatting                                                          */
/* ------------------------------------------------------------------ */

void device_format_size(unsigned long long bytes, char *out, size_t outlen) {
    static const char *units[] = { "B", "K", "M", "G", "T", "P" };
    double val = (double)bytes;
    int u = 0;
    while (val >= 1024.0 && u < 5) { val /= 1024.0; u++; }
    if (u == 0) snprintf(out, outlen, "%.0f%s", val, units[u]);
    else snprintf(out, outlen, "%.*f%s", SIZE_DECIMAL_PLACES, val, units[u]);
}

/* ------------------------------------------------------------------ */
/* icon / color resolution                                             */
/* ------------------------------------------------------------------ */

static const char *icon_by_kind(const Device *d) {
#if DEVICE_ICON_BY_KIND
    if (d->connection_bus && !strcasecmp(d->connection_bus, "sdio")) return ICON_KIND_SD_CARD;
    if (d->connection_bus && !strcasecmp(d->connection_bus, "usb")) {
        if (d->size_bytes > 0 && d->size_bytes < (unsigned long long)200 * 1024 * 1024 * 1024ULL)
            return ICON_KIND_USB_STICK;
        return ICON_KIND_EXTERNAL_HDD;
    }
#endif
    (void)d;
    return NULL;
}

const char *device_effective_icon(const Device *d) {
#if ENABLE_LUKS
    if (d->is_locked) return ICON_LUKS_LOCKED;
#endif
    const DeviceOverride *ov = find_override(d);
    if (ov) {
        const char *specific = d->is_mounted ? ov->icon_mounted : ov->icon_unmounted;
        if (specific && specific[0]) return specific;
        if (ov->icon && ov->icon[0]) return ov->icon;
    }
    const char *kind = icon_by_kind(d);
    if (kind) return kind;
    const char *state_icon = d->is_mounted ? ICON_DEVICE_MOUNTED : ICON_DEVICE_UNMOUNTED;
    if (state_icon[0]) return state_icon;
    return ICON_DEVICE_GENERIC;
}

static void resolve_color(Device *d) {
    const DeviceOverride *ov = find_override(d);
    if (ov && ov->color && ov->color[0]) {
        snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", ov->color);
        return;
    }
    if (!d->is_mounted) {
        snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", DEVICE_COLOR_UNMOUNTED);
        return;
    }
#if DEVICE_COLOR_MODE == COLOR_MODE_RAMP
    if (d->usage_valid) {
        const char *chosen = SPACE_RAMP[SPACE_RAMP_COUNT - 1].color;
        for (int i = 0; i < SPACE_RAMP_COUNT; i++) {
            if (d->percent_free >= SPACE_RAMP[i].min_percent_free) {
                chosen = SPACE_RAMP[i].color;
                break;
            }
        }
        snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", chosen);
        return;
    }
#endif
    snprintf(d->resolved_color, sizeof(d->resolved_color), "%s", DEVICE_COLOR_CONSTANT);
}

/* ------------------------------------------------------------------ */
/* classification                                                      */
/* ------------------------------------------------------------------ */

static int bus_in_external_list(const char *bus) {
    if (!bus) return 0;
    for (int i = 0; EXTERNAL_BUS_LIST[i]; i++)
        if (strcasecmp(bus, EXTERNAL_BUS_LIST[i]) == 0) return 1;
    return 0;
}

static int classify_external(const UdisksRawObject *o) {
    if (o->hint_system) return 0;
    if (o->drive_removable) return 1;
    if (bus_in_external_list(o->connection_bus)) return 1;
    return 0;
}

static int is_protected_mount(const char *mount_point, int hint_system) {
    if (hint_system) return 1;
    if (!mount_point) return 0;
    for (int i = 0; PROTECTED_MOUNT_PREFIXES[i]; i++) {
        const char *p = PROTECTED_MOUNT_PREFIXES[i];
        if (!strcmp(p, "/")) {
            if (!strcmp(mount_point, "/")) return 1;
            continue;
        }
        size_t plen = strlen(p);
        if (!strncmp(mount_point, p, plen) && (mount_point[plen] == '\0' || mount_point[plen] == '/'))
            return 1;
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* usage                                                               */
/* ------------------------------------------------------------------ */

static void refresh_usage_one(Device *d) {
    if (!d->is_mounted || !d->mount_point) {
        d->usage_valid = 0;
        return;
    }
    struct statvfs vfs;
    if (statvfs(d->mount_point, &vfs) != 0) {
        d->usage_valid = 0;
        return;
    }
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

void device_list_refresh_usage(DeviceList *list) {
    for (int i = 0; i < list->count; i++) {
        refresh_usage_one(&list->items[i]);
        resolve_color(&list->items[i]);
    }
}

/* ------------------------------------------------------------------ */
/* build                                                                */
/* ------------------------------------------------------------------ */

static int should_hide_raw(const UdisksRawObject *o) {
    if (o->hint_ignore) return 1;

    if (o->device_node) {
        if (FILTER_HIDE_LOOP_DEVICES && !strncmp(o->device_node, "/dev/loop", 9)) return 1;
        if (FILTER_HIDE_ZRAM_DEVICES && !strncmp(o->device_node, "/dev/zram", 9)) return 1;
    }

    /* Anything without a recognized filesystem (extended partitions,
     * empty partition tables, swap) is skipped. LUKS containers are
     * handled separately in device_list_build() *before* this check
     * runs against them, since a locked container legitimately has no
     * Filesystem interface yet. */
    if (FILTER_REQUIRE_FILESYSTEM && !o->has_filesystem) return 1;

    if (FILTER_MIN_SIZE_BYTES > 0 && o->size < (unsigned long long)FILTER_MIN_SIZE_BYTES) return 1;

    for (int i = 0; HIDDEN_DEVICES[i]; i++)
        if (raw_matches_pattern(o, HIDDEN_DEVICES[i])) return 1;

    return 0;
}

static void fill_common_fields(Device *d, const UdisksRawObject *o) {
    d->object_path = strdup(o->path);
    d->drive_object_path = o->drive_path ? strdup(o->drive_path) : NULL;
    d->device_node = strdup(o->device_node ? o->device_node : "");
    d->label = strdup(o->id_label ? o->id_label : "");
    d->uuid = strdup(o->id_uuid ? o->id_uuid : "");
    d->fs_type = strdup(o->id_type ? o->id_type : "");
    d->size_bytes = o->size;
    d->read_only = o->read_only;
    d->hint_system = o->hint_system;
    d->is_loop = o->has_loop;
    d->loop_backing_file = o->loop_backing_file ? strdup(o->loop_backing_file) : NULL;

    d->drive_vendor = strdup(o->drive_vendor ? o->drive_vendor : "");
    d->drive_model = strdup(o->drive_model ? o->drive_model : "");
    d->drive_serial = strdup(o->drive_serial ? o->drive_serial : "");
    d->connection_bus = strdup(o->connection_bus ? o->connection_bus : "");
    d->removable = o->drive_removable;
    d->ejectable = o->drive_ejectable;
    d->can_power_off = o->drive_can_power_off;
}

static void resolve_display_name(Device *d) {
    const DeviceOverride *ov = find_override(d);
    if (ov && ov->display_name && ov->display_name[0]) {
        snprintf(d->display_name, sizeof(d->display_name), "%s", ov->display_name);
    } else if (d->label[0]) {
        snprintf(d->display_name, sizeof(d->display_name), "%s", d->label);
    } else {
        snprintf(d->display_name, sizeof(d->display_name), "%s", d->device_node);
    }
}

int device_list_build(DeviceList *list) {
    device_list_free(list);

    UdisksRawObject *raw = NULL;
    int n_raw = udisks_get_all(&raw);
    if (n_raw < 0) {
        list->items = NULL;
        list->count = 0;
        return -1;
    }

    Device *items = NULL;
    int count = 0;

    for (int i = 0; i < n_raw; i++) {
        UdisksRawObject *o = &raw[i];

        if (o->has_encrypted) {
            /* Is there a currently-unlocked cleartext child pointing
             * back at this container? If so, that cleartext object
             * gets its own row below (with parent_luks_path set) and
             * this container row is skipped entirely -- one row per
             * physical drive, not two. */
            int has_unlocked_child = 0;
            for (int j = 0; j < n_raw; j++) {
                if (raw[j].crypto_backing_device && !strcmp(raw[j].crypto_backing_device, o->path)) {
                    has_unlocked_child = 1;
                    break;
                }
            }
            if (has_unlocked_child) continue;

#if ENABLE_LUKS
            if (o->hint_ignore) continue;
            int skip = 0;
            for (int h = 0; HIDDEN_DEVICES[h]; h++)
                if (raw_matches_pattern(o, HIDDEN_DEVICES[h])) { skip = 1; break; }
            if (skip) continue;

            int external = classify_external(o);
            if (!external && !SHOW_INTERNAL_DEVICES) continue;

            Device d;
            memset(&d, 0, sizeof(d));
            fill_common_fields(&d, o);
            d.is_encrypted = 1;
            d.is_locked = 1;
            d.is_external = external;
            d.is_protected = is_protected_mount(NULL, d.hint_system);
            resolve_display_name(&d);
            resolve_color(&d); /* !is_mounted -> DEVICE_COLOR_UNMOUNTED, same as any unmounted device */

            items = realloc(items, sizeof(Device) * (count + 1));
            items[count++] = d;
#endif
            continue; /* never fall through to the generic path for a container row */
        }

        if (should_hide_raw(o)) continue;

        int external = classify_external(o);
        if (!external && !SHOW_INTERNAL_DEVICES) continue;

        Device d;
        memset(&d, 0, sizeof(d));
        fill_common_fields(&d, o);

        d.is_mounted = (o->n_mount_points > 0 && o->mount_points[0] && o->mount_points[0][0]);
        d.mount_point = d.is_mounted ? strdup(o->mount_points[0]) : NULL;

        d.is_external = external;
        d.is_protected = is_protected_mount(d.mount_point, d.hint_system);

        if (o->crypto_backing_device) {
            d.is_encrypted = 1;
            d.parent_luks_path = strdup(o->crypto_backing_device);
            for (int k = 0; k < n_raw; k++) {
                if (!strcmp(raw[k].path, o->crypto_backing_device)) {
                    d.parent_luks_uuid = strdup(raw[k].id_uuid ? raw[k].id_uuid : "");
                    break;
                }
            }
        }

        refresh_usage_one(&d);
        resolve_display_name(&d);
        resolve_color(&d);

#if ENABLE_MOUNT_POINT_SYMLINKS
        if (d.is_mounted && d.uuid[0]) {
            char *sl = state_get_symlink(d.uuid);
            d.symlink_path = sl; /* NULL if none configured */
        }
#endif

        items = realloc(items, sizeof(Device) * (count + 1));
        items[count++] = d;
    }

    udisks_free_raw_objects(raw, n_raw);

    list->items = items;
    list->count = count;
    return count;
}

void device_list_free(DeviceList *list) {
    for (int i = 0; i < list->count; i++) {
        Device *d = &list->items[i];
        free(d->object_path);
        free(d->drive_object_path);
        free(d->device_node);
        free(d->label);
        free(d->uuid);
        free(d->fs_type);
        free(d->mount_point);
        free(d->loop_backing_file);
        free(d->drive_vendor);
        free(d->drive_model);
        free(d->drive_serial);
        free(d->connection_bus);
        free(d->symlink_path);
        free(d->parent_luks_path);
        free(d->parent_luks_uuid);
    }
    free(list->items);
    list->items = NULL;
    list->count = 0;
}

Device *device_list_find(DeviceList *list, const char *id) {
    if (!id || !id[0]) return NULL;
    for (int i = 0; i < list->count; i++)
        if (!strcmp(list->items[i].object_path, id)) return &list->items[i];
    for (int i = 0; i < list->count; i++)
        if (!strcmp(list->items[i].device_node, id)) return &list->items[i];
    for (int i = 0; i < list->count; i++)
        if (list->items[i].uuid[0] && !strcasecmp(list->items[i].uuid, id)) return &list->items[i];
    return NULL;
}
