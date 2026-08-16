#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "render.h"
#include "config.h"

/* ------------------------------------------------------------------ */

const char *render_self_path(const char *argv0) {
    static char path[4096];
    static int resolved = 0;
    if (resolved) return path;
    resolved = 1;

    ssize_t n = readlink("/proc/self/exe", path, sizeof(path) - 1);
    if (n > 0) {
        path[n] = '\0';
        return path;
    }
    snprintf(path, sizeof(path), "%s", argv0 ? argv0 : "polybar-udisks");
    return path;
}

/* Wraps `s` in single quotes for safe embedding in a shell command
 * line (polybar runs click actions via the shell), escaping any
 * embedded single quotes with the standard '\'' trick. */
static void shell_quote(const char *s, char *out, size_t outlen) {
    size_t o = 0;
    if (o + 1 < outlen) out[o++] = '\'';
    for (const char *p = s; *p && o + 5 < outlen; p++) {
        if (*p == '\'') {
            out[o++] = '\''; out[o++] = '\\'; out[o++] = '\''; out[o++] = '\'';
        } else {
            out[o++] = *p;
        }
    }
    if (o + 1 < outlen) out[o++] = '\'';
    out[o] = '\0';
}

static void substitute_generic(const char *tmpl, const Device *d, int quote, char *out, size_t outlen) {
    char self_v[512], id_v[512], node_v[512], name_v[512], mp_v[512];
    const char *self_raw = render_self_path(NULL);
    const char *id_raw = d ? d->object_path : "";
    const char *node_raw = d ? d->device_node : "";
    const char *name_raw = d ? d->display_name : "";
    const char *mp_raw = d && d->mount_point ? d->mount_point : "";

    if (quote) {
        shell_quote(self_raw, self_v, sizeof(self_v));
        shell_quote(id_raw, id_v, sizeof(id_v));
        shell_quote(node_raw, node_v, sizeof(node_v));
        shell_quote(name_raw, name_v, sizeof(name_v));
        shell_quote(mp_raw, mp_v, sizeof(mp_v));
    } else {
        snprintf(self_v, sizeof(self_v), "%s", self_raw);
        snprintf(id_v, sizeof(id_v), "%s", id_raw);
        snprintf(node_v, sizeof(node_v), "%s", node_raw);
        snprintf(name_v, sizeof(name_v), "%s", name_raw);
        snprintf(mp_v, sizeof(mp_v), "%s", mp_raw);
    }

    out[0] = '\0';
    size_t o = 0;
    for (const char *p = tmpl; *p && o < outlen - 1; ) {
        const char *rep = NULL;
        size_t skip = 0;
        if (!strncmp(p, "{SELF}", 6))       { rep = self_v; skip = 6; }
        else if (!strncmp(p, "{ID}", 4))    { rep = id_v; skip = 4; }
        else if (!strncmp(p, "{NODE}", 6))  { rep = node_v; skip = 6; }
        else if (!strncmp(p, "{NAME}", 6))  { rep = name_v; skip = 6; }
        else if (!strncmp(p, "{MOUNTPOINT}", 12)) { rep = mp_v; skip = 12; }

        if (rep) {
            size_t rl = strlen(rep);
            if (o + rl >= outlen) rl = outlen - 1 - o;
            memcpy(out + o, rep, rl);
            o += rl;
            p += skip;
        } else {
            out[o++] = *p++;
        }
    }
    out[o] = '\0';
}

static void substitute(const char *tmpl, const Device *d, char *out, size_t outlen) {
    substitute_generic(tmpl, d, 1, out, outlen);
}

void render_substitute(const char *tmpl, const Device *d, char *out, size_t outlen) {
    substitute_generic(tmpl, d, 1, out, outlen);
}

void render_substitute_raw(const char *tmpl, const Device *d, char *out, size_t outlen) {
    substitute_generic(tmpl, d, 0, out, outlen);
}

/* UTF-8-aware truncation: cuts at `max_chars` codepoints, not bytes. */
static void truncate_utf8(const char *in, int max_chars, char *out, size_t outlen) {
    if (max_chars <= 0) { snprintf(out, outlen, "%s", in); return; }
    int chars = 0;
    size_t bytes = 0;
    size_t inlen = strlen(in);
    while (bytes < inlen) {
        unsigned char c = (unsigned char)in[bytes];
        size_t clen = (c < 0x80) ? 1 : (c >> 5 == 0x6) ? 2 : (c >> 4 == 0xE) ? 3 : (c >> 3 == 0x1E) ? 4 : 1;
        if (chars >= max_chars) break;
        bytes += clen;
        chars++;
    }
    if (bytes >= inlen) {
        snprintf(out, outlen, "%s", in);
        return;
    }
    size_t suf_len = strlen(BAR_NAME_TRUNCATE_SUFFIX);
    size_t copy = bytes < outlen - suf_len - 1 ? bytes : outlen - suf_len - 1;
    memcpy(out, in, copy);
    memcpy(out + copy, BAR_NAME_TRUNCATE_SUFFIX, suf_len);
    out[copy + suf_len] = '\0';
}

/* ------------------------------------------------------------------ */
/* bar text                                                             */
/* ------------------------------------------------------------------ */

static void append_action_wraps_open(char *buf, size_t buflen, const Device *d) {
    static const char *disk_slots[5] = { POLYBAR_ACTION_1, POLYBAR_ACTION_2, POLYBAR_ACTION_3,
                                          POLYBAR_ACTION_4, POLYBAR_ACTION_5 };
    static const char *iso_slots[5] = { POLYBAR_ISO_ACTION_1, POLYBAR_ISO_ACTION_2, POLYBAR_ISO_ACTION_3,
                                         POLYBAR_ISO_ACTION_4, POLYBAR_ISO_ACTION_5 };
    const char **slots = (d->is_loop) ? iso_slots : disk_slots;
    for (int i = 0; i < 5; i++) {
        const char *tmpl = slots[i];
        char default_buf[64];
        if (i == 0 && (!tmpl || !tmpl[0])) {
            snprintf(default_buf, sizeof(default_buf), d->is_loop ? "{SELF} --iso -i {ID} -m" : "{SELF} -i {ID} -m");
            tmpl = default_buf;
        }
        if (!tmpl || !tmpl[0]) continue;
        char cmd[3072];
        substitute(tmpl, d, cmd, sizeof(cmd));
        char frag[3200];
        snprintf(frag, sizeof(frag), "%%{A%d:%s:}", i + 1, cmd);
        strncat(buf, frag, buflen - strlen(buf) - 1);
    }
}

static void append_action_wraps_close(char *buf, size_t buflen, const Device *d) {
    static const char *disk_slots[5] = { POLYBAR_ACTION_1, POLYBAR_ACTION_2, POLYBAR_ACTION_3,
                                          POLYBAR_ACTION_4, POLYBAR_ACTION_5 };
    static const char *iso_slots[5] = { POLYBAR_ISO_ACTION_1, POLYBAR_ISO_ACTION_2, POLYBAR_ISO_ACTION_3,
                                         POLYBAR_ISO_ACTION_4, POLYBAR_ISO_ACTION_5 };
    const char **slots = (d->is_loop) ? iso_slots : disk_slots;
    for (int i = 4; i >= 0; i--) {
        const char *tmpl = slots[i];
        if (i == 0 && (!tmpl || !tmpl[0])) tmpl = "x"; /* non-empty sentinel, default slot 1 is always active */
        if (!tmpl || !tmpl[0]) continue;
        strncat(buf, "%{A}", buflen - strlen(buf) - 1);
    }
}

static void render_one_device(const Device *d, char *out, size_t outlen) {
    char body[1024] = "";

    const char *icon = device_effective_icon(d);
    strncat(body, icon, sizeof(body) - strlen(body) - 1);

    if (BAR_SHOW_NAME) {
        char name_buf[256];
        truncate_utf8(d->display_name, BAR_NAME_MAX_CHARS, name_buf, sizeof(name_buf));
        char piece[300];
        snprintf(piece, sizeof(piece), "%%{O%d}%s", ICON_NAME_SPACING_PX, name_buf);
        strncat(body, piece, sizeof(body) - strlen(body) - 1);
    }

    char stats[256] = "";
    if (d->usage_valid && !d->is_loop) {
        char sz[16];
        int wrote = 0;
        if (BAR_SHOW_USED) {
            device_format_size(d->used_bytes, sz, sizeof(sz));
            strncat(stats, sz, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_FREE) {
            if (wrote) strncat(stats, "/", sizeof(stats) - strlen(stats) - 1);
            device_format_size(d->free_bytes, sz, sizeof(sz));
            strncat(stats, sz, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_TOTAL) {
            if (wrote) strncat(stats, "/", sizeof(stats) - strlen(stats) - 1);
            device_format_size(d->total_bytes, sz, sizeof(sz));
            strncat(stats, sz, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_PERCENT_USED) {
            char p[16];
            snprintf(p, sizeof(p), "%s%d%%", wrote ? " " : "", d->percent_used);
            strncat(stats, p, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_PERCENT_FREE) {
            char p[16];
            snprintf(p, sizeof(p), "%s%d%% free", wrote ? " " : "", d->percent_free);
            strncat(stats, p, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
    }
    if (stats[0]) {
        char piece[300];
        snprintf(piece, sizeof(piece), "%%{O%d}%s", NAME_STATS_SPACING_PX, stats);
        strncat(body, piece, sizeof(body) - strlen(body) - 1);
    }

    if (BAR_SHOW_MOUNT_STATE_SUFFIX) {
        strncat(body, " ", sizeof(body) - strlen(body) - 1);
        strncat(body, d->is_mounted ? ICON_MOUNT_STATE_MOUNTED : ICON_MOUNT_STATE_UNMOUNTED,
                 sizeof(body) - strlen(body) - 1);
    }

    char low_prefix[64] = "";
    if (!d->is_loop && LOW_SPACE_THRESHOLD_PERCENT >= 0 && d->usage_valid && d->is_mounted &&
        d->percent_free <= LOW_SPACE_THRESHOLD_PERCENT) {
        snprintf(low_prefix, sizeof(low_prefix), "%%{F%s}%s%%{F-} ", "#fb4934", ICON_LOW_SPACE);
    }

    char open_actions[4096] = "";
    append_action_wraps_open(open_actions, sizeof(open_actions), d);
    char close_actions[128] = "";
    append_action_wraps_close(close_actions, sizeof(close_actions), d);

    snprintf(out, outlen, "%s%s%%{F%s}%s%%{F-}%s",
             low_prefix, open_actions, d->resolved_color, body, close_actions);
}

/* ------------------------------------------------------------------ */
/* mtp (phone) bar rendering                                            */
/* ------------------------------------------------------------------ */

static void mtp_substitute(const char *tmpl, const MtpDevice *m, char *out, size_t outlen) {
    char self_q[512], id_q[512], name_q[512], mp_q[512];
    shell_quote(render_self_path(NULL), self_q, sizeof(self_q));

    char busdev[32] = "";
    const char *id_raw = "";
    if (m) {
        if (m->serial[0]) id_raw = m->serial;
        else { snprintf(busdev, sizeof(busdev), "%d:%d", m->busnum, m->devnum); id_raw = busdev; }
    }
    shell_quote(id_raw, id_q, sizeof(id_q));
    shell_quote(m ? m->display_name : "", name_q, sizeof(name_q));
    shell_quote(m && m->mount_point ? m->mount_point : "", mp_q, sizeof(mp_q));

    out[0] = '\0';
    size_t o = 0;
    for (const char *p = tmpl; *p && o < outlen - 1; ) {
        const char *rep = NULL;
        size_t skip = 0;
        if (!strncmp(p, "{SELF}", 6)) { rep = self_q; skip = 6; }
        else if (!strncmp(p, "{ID}", 4)) { rep = id_q; skip = 4; }
        else if (!strncmp(p, "{NAME}", 6)) { rep = name_q; skip = 6; }
        else if (!strncmp(p, "{MOUNTPOINT}", 12)) { rep = mp_q; skip = 12; }

        if (rep) {
            size_t rl = strlen(rep);
            if (o + rl >= outlen) rl = outlen - 1 - o;
            memcpy(out + o, rep, rl);
            o += rl;
            p += skip;
        } else {
            out[o++] = *p++;
        }
    }
    out[o] = '\0';
}

static void append_mtp_action_wraps_open(char *buf, size_t buflen, const MtpDevice *m) {
    static const char *slots[5] = { POLYBAR_MTP_ACTION_1, POLYBAR_MTP_ACTION_2, POLYBAR_MTP_ACTION_3,
                                     POLYBAR_MTP_ACTION_4, POLYBAR_MTP_ACTION_5 };
    for (int i = 0; i < 5; i++) {
        const char *tmpl = slots[i];
        char default_buf[64];
        if (i == 0 && (!tmpl || !tmpl[0])) {
            snprintf(default_buf, sizeof(default_buf), "{SELF} --mtp -i {ID} -m");
            tmpl = default_buf;
        }
        if (!tmpl || !tmpl[0]) continue;
        char cmd[3072];
        mtp_substitute(tmpl, m, cmd, sizeof(cmd));
        char frag[3200];
        snprintf(frag, sizeof(frag), "%%{A%d:%s:}", i + 1, cmd);
        strncat(buf, frag, buflen - strlen(buf) - 1);
    }
}

static void append_mtp_action_wraps_close(char *buf, size_t buflen, const MtpDevice *m) {
    static const char *slots[5] = { POLYBAR_MTP_ACTION_1, POLYBAR_MTP_ACTION_2, POLYBAR_MTP_ACTION_3,
                                     POLYBAR_MTP_ACTION_4, POLYBAR_MTP_ACTION_5 };
    for (int i = 4; i >= 0; i--) {
        const char *tmpl = slots[i];
        if (i == 0 && (!tmpl || !tmpl[0])) tmpl = "x";
        if (!tmpl || !tmpl[0]) continue;
        strncat(buf, "%{A}", buflen - strlen(buf) - 1);
    }
    (void)m;
}

static void render_one_mtp(const MtpDevice *m, char *out, size_t outlen) {
    char body[1024] = "";

    const char *icon = m->is_mounted
        ? (ICON_PHONE_MOUNTED[0] ? ICON_PHONE_MOUNTED : ICON_PHONE_GENERIC)
        : (ICON_PHONE_UNMOUNTED[0] ? ICON_PHONE_UNMOUNTED : ICON_PHONE_GENERIC);
    strncat(body, icon, sizeof(body) - strlen(body) - 1);

    if (BAR_SHOW_NAME) {
        char name_buf[256];
        truncate_utf8(m->display_name, BAR_NAME_MAX_CHARS, name_buf, sizeof(name_buf));
        char piece[300];
        snprintf(piece, sizeof(piece), "%%{O%d}%s", ICON_NAME_SPACING_PX, name_buf);
        strncat(body, piece, sizeof(body) - strlen(body) - 1);
    }

    char stats[256] = "";
    if (m->usage_valid) {
        char sz[16];
        int wrote = 0;
        if (BAR_SHOW_USED) {
            device_format_size(m->used_bytes, sz, sizeof(sz));
            strncat(stats, sz, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_FREE) {
            if (wrote) strncat(stats, "/", sizeof(stats) - strlen(stats) - 1);
            device_format_size(m->free_bytes, sz, sizeof(sz));
            strncat(stats, sz, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_TOTAL) {
            if (wrote) strncat(stats, "/", sizeof(stats) - strlen(stats) - 1);
            device_format_size(m->total_bytes, sz, sizeof(sz));
            strncat(stats, sz, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_PERCENT_USED) {
            char p[16];
            snprintf(p, sizeof(p), "%s%d%%", wrote ? " " : "", m->percent_used);
            strncat(stats, p, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
        if (BAR_SHOW_PERCENT_FREE) {
            char p[16];
            snprintf(p, sizeof(p), "%s%d%% free", wrote ? " " : "", m->percent_free);
            strncat(stats, p, sizeof(stats) - strlen(stats) - 1);
            wrote = 1;
        }
    }
    if (stats[0]) {
        char piece[300];
        snprintf(piece, sizeof(piece), "%%{O%d}%s", NAME_STATS_SPACING_PX, stats);
        strncat(body, piece, sizeof(body) - strlen(body) - 1);
    }

    char open_actions[4096] = "";
    append_mtp_action_wraps_open(open_actions, sizeof(open_actions), m);
    char close_actions[128] = "";
    append_mtp_action_wraps_close(close_actions, sizeof(close_actions), m);

    snprintf(out, outlen, "%s%%{F%s}%s%%{F-}%s", open_actions, m->resolved_color, body, close_actions);
}

void render_bar(const DeviceList *list, const MtpDeviceList *mtp_list) {
    int total = list->count + (mtp_list ? mtp_list->count : 0);

    if (total == 0) {
        if (SHOW_ICON_WHEN_NO_DEVICES) {
            char open_actions[2048] = "";
            static const char *slots[5] = { NO_DEVICE_ACTION_1, NO_DEVICE_ACTION_2, NO_DEVICE_ACTION_3,
                                             NO_DEVICE_ACTION_4, NO_DEVICE_ACTION_5 };
            int any = 0;
            for (int i = 0; i < 5; i++) {
                if (!slots[i] || !slots[i][0]) continue;
                char cmd[1024];
                substitute(slots[i], NULL, cmd, sizeof(cmd));
                char frag[1100];
                snprintf(frag, sizeof(frag), "%%{A%d:%s:}", i + 1, cmd);
                strncat(open_actions, frag, sizeof(open_actions) - strlen(open_actions) - 1);
                any = 1;
            }
            printf("%s%%{F%s}%s%%{F-}%s\n",
                   open_actions, COLOR_NO_DEVICES, ICON_NO_DEVICES, any ? "%{A}" : "");
        } else {
            printf("\n");
        }
        return;
    }

    char line[8192] = "";
    int wrote = 0;
    for (int i = 0; i < list->count; i++) {
        char seg[2048];
        render_one_device(&list->items[i], seg, sizeof(seg));
        if (wrote) strncat(line, " " SEPARATOR " ", sizeof(line) - strlen(line) - 1);
        strncat(line, seg, sizeof(line) - strlen(line) - 1);
        wrote = 1;
    }
    if (mtp_list) {
        for (int i = 0; i < mtp_list->count; i++) {
            char seg[2048];
            render_one_mtp(&mtp_list->items[i], seg, sizeof(seg));
            if (wrote) strncat(line, " " SEPARATOR " ", sizeof(line) - strlen(line) - 1);
            strncat(line, seg, sizeof(line) - strlen(line) - 1);
            wrote = 1;
        }
    }
    printf("%s\n", line);
}

/* ------------------------------------------------------------------ */
/* json                                                                 */
/* ------------------------------------------------------------------ */

static void json_escape(const char *s, char *out, size_t outlen) {
    size_t o = 0;
    for (const char *p = s; *p && o + 2 < outlen; p++) {
        if (*p == '"' || *p == '\\') { out[o++] = '\\'; out[o++] = *p; }
        else if (*p == '\n') { out[o++] = '\\'; out[o++] = 'n'; }
        else out[o++] = *p;
    }
    out[o] = '\0';
}

void render_json(const DeviceList *list, const MtpDeviceList *mtp_list) {
    printf("[");
    int wrote = 0;
    for (int i = 0; i < list->count; i++) {
        Device *d = &list->items[i];
        char name_e[512], node_e[512], label_e[512], uuid_e[128], fs_e[64],
             mp_e[1024], sym_e[1024], vendor_e[256], model_e[256];
        json_escape(d->display_name, name_e, sizeof(name_e));
        json_escape(d->device_node, node_e, sizeof(node_e));
        json_escape(d->label, label_e, sizeof(label_e));
        json_escape(d->uuid, uuid_e, sizeof(uuid_e));
        json_escape(d->fs_type, fs_e, sizeof(fs_e));
        json_escape(d->mount_point ? d->mount_point : "", mp_e, sizeof(mp_e));
        json_escape(d->symlink_path ? d->symlink_path : "", sym_e, sizeof(sym_e));
        json_escape(d->drive_vendor, vendor_e, sizeof(vendor_e));
        json_escape(d->drive_model, model_e, sizeof(model_e));

        printf("%s{"
               "\"kind\":\"%s\",\"id\":\"%s\",\"name\":\"%s\",\"node\":\"%s\",\"label\":\"%s\","
               "\"uuid\":\"%s\",\"fs_type\":\"%s\",\"external\":%s,\"removable\":%s,"
               "\"mounted\":%s,\"mount_point\":\"%s\",\"symlink\":\"%s\","
               "\"read_only\":%s,\"protected\":%s,\"ejectable\":%s,\"can_power_off\":%s,"
               "\"encrypted\":%s,\"locked\":%s,"
               "\"size_bytes\":%llu,\"usage_valid\":%s,\"used_bytes\":%llu,"
               "\"free_bytes\":%llu,\"total_bytes\":%llu,\"percent_used\":%d,"
               "\"drive_vendor\":\"%s\",\"drive_model\":\"%s\",\"connection_bus\":\"%s\","
               "\"color\":\"%s\"}",
               wrote ? "," : "",
               d->is_loop ? "iso" : "disk",
               d->object_path, name_e, node_e, label_e,
               uuid_e, fs_e, d->is_external ? "true" : "false", d->removable ? "true" : "false",
               d->is_mounted ? "true" : "false", mp_e, sym_e,
               d->read_only ? "true" : "false", d->is_protected ? "true" : "false",
               d->ejectable ? "true" : "false", d->can_power_off ? "true" : "false",
               d->is_encrypted ? "true" : "false", d->is_locked ? "true" : "false",
               d->size_bytes, d->usage_valid ? "true" : "false", d->used_bytes,
               d->free_bytes, d->total_bytes, d->percent_used,
               vendor_e, model_e, d->connection_bus,
               d->resolved_color);
        wrote = 1;
    }
    if (mtp_list) {
        for (int i = 0; i < mtp_list->count; i++) {
            MtpDevice *m = &mtp_list->items[i];
            char name_e[512], serial_e[128], vendor_e[256], model_e[256], mp_e[1024];
            json_escape(m->display_name, name_e, sizeof(name_e));
            json_escape(m->serial, serial_e, sizeof(serial_e));
            json_escape(m->vendor, vendor_e, sizeof(vendor_e));
            json_escape(m->model, model_e, sizeof(model_e));
            json_escape(m->mount_point ? m->mount_point : "", mp_e, sizeof(mp_e));

            printf("%s{"
                   "\"kind\":\"phone\",\"id\":\"%s\",\"name\":\"%s\",\"serial\":\"%s\","
                   "\"vendor\":\"%s\",\"model\":\"%s\",\"mounted\":%s,\"mount_point\":\"%s\","
                   "\"usage_valid\":%s,\"used_bytes\":%llu,\"free_bytes\":%llu,"
                   "\"total_bytes\":%llu,\"percent_used\":%d,\"color\":\"%s\"}",
                   wrote ? "," : "",
                   serial_e[0] ? serial_e : name_e, name_e, serial_e,
                   vendor_e, model_e, m->is_mounted ? "true" : "false", mp_e,
                   m->usage_valid ? "true" : "false", m->used_bytes, m->free_bytes,
                   m->total_bytes, m->percent_used, m->resolved_color);
            wrote = 1;
        }
    }
    printf("]\n");
}
