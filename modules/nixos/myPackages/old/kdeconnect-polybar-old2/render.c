#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "render.h"
#include "dbus_client.h"
#include "actions.h"
#include "notify.h"
#include "state_file.h"
#include "config.h"

static TrackedDevice *find_or_create(RenderState *state, const char *id) {
    for (int i = 0; i < state->count; i++) {
        if (strcmp(state->devices[i].id, id) == 0) return &state->devices[i];
    }
    TrackedDevice *grown = realloc(state->devices, sizeof(TrackedDevice) * (size_t)(state->count + 1));
    if (!grown) return NULL;
    state->devices = grown;

    TrackedDevice *td = &state->devices[state->count];
    td->id = strdup(id);
    td->notified_pairing = 0;
    td->known = 0;
    td->was_reachable = 0;
    td->was_trusted = 0;
    td->was_low_battery = 0;
    state->count++;
    return td;
}

void render_state_init(RenderState *state, Display *dpy, const char *self_exe, int show_battery, int show_name) {
    state->devices = NULL;
    state->count = 0;
    state->dpy = dpy;
    state->self_exe = self_exe;
    state->show_battery = show_battery;
    state->show_name = show_name;
}

void render_state_free(RenderState *state) {
    for (int i = 0; i < state->count; i++) free(state->devices[i].id);
    free(state->devices);
    state->devices = NULL;
    state->count = 0;
}

static const char *color_for_battery(int battery) {
    for (int i = 0; i < BATTERY_BAND_COUNT; i++) {
        if (battery >= BATTERY_BANDS[i].threshold) return BATTERY_BANDS[i].color;
    }
    return BATTERY_BANDS[BATTERY_BAND_COUNT - 1].color;
}

/* Icon only (no battery percentage) -- kept separate from the percent
 * span below so the device name can be inserted between them. */
static const char *icon_only(int battery, const char *devtype) {
    static char buf[64];
    int is_tablet = (devtype && strcmp(devtype, "tablet") == 0);
    const char *icon;
    const char *color;

    if (battery == -1) {
        icon = ICON_DISCONNECTED_DEVICE;
        color = COLOR_DISCONNECTED;
    } else if (battery == -2) {
        icon = ICON_NEW_DEVICE;
        color = COLOR_NEWDEVICE;
    } else {
        icon = is_tablet ? ICON_TABLET : ICON_SMARTPHONE;
        color = color_for_battery(battery);
    }

    snprintf(buf, sizeof(buf), "%%{F%s}%s%%{F-}", color, icon);
    return buf;
}

/* Battery-colored percentage span, e.g. "%{F#fff}87%{F-}". Empty
 * string if battery < 0 (unknown/not applicable). */
static const char *percent_only(int battery) {
    static char buf[48];
    if (battery < 0) {
        buf[0] = '\0';
        return buf;
    }
    snprintf(buf, sizeof(buf), "%%{F%s}%d%%{F-}", color_for_battery(battery), battery);
    return buf;
}

typedef struct { char *buf; size_t len; size_t cap; } strbuf;

static void sb_init(strbuf *s) {
    s->cap = 256;
    s->len = 0;
    s->buf = malloc(s->cap);
    s->buf[0] = '\0';
}

static void sb_append(strbuf *s, const char *str) {
    size_t l = strlen(str);
    while (s->len + l + 1 > s->cap) {
        s->cap *= 2;
        s->buf = realloc(s->buf, s->cap);
    }
    memcpy(s->buf + s->len, str, l + 1);
    s->len += l;
}

/* Truncates `name` (UTF-8) to at most max_chars *characters* (not
 * bytes), appending DEVICE_NAME_TRUNCATE_SUFFIX if it had to shorten
 * anything. max_chars <= 0 means no limit. This is a plain character
 * count for bar text (polybar renders it with its own font, so we
 * have no pixel-width information here, unlike the menu widgets). */
static void truncate_name_chars(char *out, size_t outsz, const char *name, int max_chars) {
    if (max_chars <= 0 || !name) {
        snprintf(out, outsz, "%s", name ? name : "");
        return;
    }

    int chars = 0;
    const char *p = name;
    while (*p) {
        unsigned char c = (unsigned char)*p;
        int len = 1;
        if ((c & 0xE0) == 0xC0) len = 2;
        else if ((c & 0xF0) == 0xE0) len = 3;
        else if ((c & 0xF8) == 0xF0) len = 4;

        if (chars >= max_chars) break;
        p += len;
        chars++;
    }

    if (*p == '\0') {
        snprintf(out, outsz, "%s", name);
        return;
    }

    size_t n = (size_t)(p - name);
    if (n >= outsz) n = outsz - 1;
    memcpy(out, name, n);
    out[n] = '\0';

    size_t used = strlen(out);
    if (used < outsz - 1) {
        snprintf(out + used, outsz - used, "%s", DEVICE_NAME_TRUNCATE_SUFFIX);
    }
}

/* Expands {SELF}/{ID}/{NAME} placeholders in a POLYBAR_ACTION_* click
 * template. Not shell-quoted for the caller -- same convention as the
 * built-in default command, which quotes {NAME} itself where needed. */
static void expand_action_template(char *out, size_t outsz, const char *tmpl,
                                    const char *self_exe, const char *id, const char *name) {
    size_t out_len = 0;
    out[0] = '\0';

    for (const char *p = tmpl; *p && out_len + 1 < outsz; ) {
        const char *rep = NULL;
        size_t skip = 0;

        if (strncmp(p, "{SELF}", 6) == 0) { rep = self_exe; skip = 6; }
        else if (strncmp(p, "{ID}", 4) == 0) { rep = id; skip = 4; }
        else if (strncmp(p, "{NAME}", 6) == 0) { rep = name; skip = 6; }

        if (rep) {
            size_t rl = strlen(rep);
            size_t space = outsz - out_len - 1;
            size_t n = rl < space ? rl : space;
            memcpy(out + out_len, rep, n);
            out_len += n;
            out[out_len] = '\0';
            p += skip;
        } else {
            out[out_len++] = *p++;
            out[out_len] = '\0';
        }
    }
}

/* Appends one %{An:cmd:} tag per configured (or, for slot 1, defaulted)
 * polybar click action to `piece`. Returns how many were opened, so
 * the caller can close the same number of %{A} tags afterward. */
static int append_action_tags(strbuf *piece, const char *self_exe, const char *id,
                               const char *name, const char *default_a1_cmd) {
    static const char *templates[5] = {
        POLYBAR_ACTION_1, POLYBAR_ACTION_2, POLYBAR_ACTION_3, POLYBAR_ACTION_4, POLYBAR_ACTION_5
    };
    int opened = 0;

    for (int slot = 0; slot < 5; slot++) {
        const char *tmpl = templates[slot];
        char cmd[600];

        if (slot == 0 && (!tmpl || tmpl[0] == '\0')) {
            snprintf(cmd, sizeof(cmd), "%s", default_a1_cmd);
        } else if (tmpl && tmpl[0] != '\0') {
            expand_action_template(cmd, sizeof(cmd), tmpl, self_exe, id, name);
        } else {
            continue;
        }

        char tag[700];
        snprintf(tag, sizeof(tag), "%%{A%d:%s:}", slot + 1, cmd);
        sb_append(piece, tag);
        opened++;
    }

    return opened;
}

char *render_module(RenderState *state) {
    int count = 0;
    char **ids = kdc_get_device_ids(&count);

    strbuf out;
    sb_init(&out);

    for (int i = 0; i < count; i++) {
        char devpath[300];
        kdc_device_path(devpath, sizeof(devpath), ids[i]);

        char *name = NULL, *devtype = NULL;
        kdc_get_string(devpath, KDC_DEVICE_IFACE, "name", &name);
        kdc_get_string(devpath, KDC_DEVICE_IFACE, "type", &devtype);

        int reachable = 0, trusted = 0;
        kdc_get_bool(devpath, KDC_DEVICE_IFACE, "isReachable", &reachable);
        kdc_is_paired(devpath, &trusted);

        TrackedDevice *td = find_or_create(state, ids[i]);

        char piece_static[1024];
        char *piece_dyn = NULL;
        const char *piece = piece_static;

        if (reachable && trusted) {
            char batpath[320];
            snprintf(batpath, sizeof(batpath), "%s/battery", devpath);
            int battery = -1;
            kdc_get_int(batpath, KDC_BATTERY_IFACE, "charge", &battery);

            int is_low = (LOW_BATTERY_THRESHOLD >= 0 && battery >= 0 && battery <= LOW_BATTERY_THRESHOLD);
            const char *low_prefix = is_low ? ICON_LOW_BATTERY : "";

            char default_cmd[300];
            snprintf(default_cmd, sizeof(default_cmd), "%s -n '%s' -i %s -m",
                     state->self_exe, name ? name : "", ids[i]);

            strbuf piece_sb;
            sb_init(&piece_sb);

            int opened = append_action_tags(&piece_sb, state->self_exe, ids[i], name ? name : "", default_cmd);

            sb_append(&piece_sb, low_prefix);
            sb_append(&piece_sb, icon_only(battery, devtype));

            int have_name = state->show_name && name && name[0] != '\0';
            int have_percent = state->show_battery && battery >= 0;

            if (have_name) {
                char spacer[24];
                snprintf(spacer, sizeof(spacer), "%%{O%d}", ICON_NAME_SPACING_PX);
                sb_append(&piece_sb, spacer);

                char truncated[256];
                truncate_name_chars(truncated, sizeof(truncated), name, DEVICE_NAME_MAX_CHARS);
                sb_append(&piece_sb, truncated);
            }

            if (have_percent) {
                char spacer[24];
                int px = have_name ? NAME_BATTERY_SPACING_PX : ICON_NAME_SPACING_PX;
                snprintf(spacer, sizeof(spacer), "%%{O%d}", px);
                sb_append(&piece_sb, spacer);
                sb_append(&piece_sb, percent_only(battery));
            }

            for (int k = 0; k < opened; k++) sb_append(&piece_sb, "%{A}");
            sb_append(&piece_sb, SEPARATOR);

            piece_dyn = piece_sb.buf;
            piece = piece_dyn;

            if (td) {
                if (td->known && !td->was_reachable) {
                    save_last_device(ids[i]);
                    if (NOTIFY_ON_CONNECT) {
                        char msg[256];
                        snprintf(msg, sizeof(msg), "%s connected", name ? name : ids[i]);
                        kdc_notify(NOTIFY_APP_NAME, msg);
                    }
                }
                if (NOTIFY_ON_LOW_BATTERY && is_low && !td->was_low_battery) {
                    char msg[256];
                    snprintf(msg, sizeof(msg), "%s battery at %d%%", name ? name : ids[i], battery);
                    kdc_notify("Low battery", msg);
                }
                td->was_low_battery = is_low;
                td->was_reachable = 1;
                td->was_trusted = 1;
                td->known = 1;
                td->notified_pairing = 0;
            }

        } else if (!reachable && trusted) {
            snprintf(piece_static, sizeof(piece_static), "%s%s", icon_only(-1, devtype), SEPARATOR);

            if (td) {
                if (NOTIFY_ON_DISCONNECT && td->known && td->was_reachable) {
                    char msg[256];
                    snprintf(msg, sizeof(msg), "%s disconnected", name ? name : ids[i]);
                    kdc_notify(NOTIFY_APP_NAME, msg);
                }
                td->was_reachable = 0;
                td->was_trusted = 1;
                td->known = 1;
                td->was_low_battery = 0;
                td->notified_pairing = 0;
            }

        } else {
            int has_pairing = 0;
            kdc_get_bool(devpath, KDC_DEVICE_IFACE, "isPairRequestedByPeer", &has_pairing);

            if (has_pairing && td && !td->notified_pairing) {
                td->notified_pairing = 1;
                if (NOTIFY_ON_PAIR_REQUEST) {
                    char msg[256];
                    snprintf(msg, sizeof(msg), "%s wants to pair", name ? name : ids[i]);
                    kdc_notify("KDE Connect pairing request", msg);
                }
                if (state->dpy) {
                    action_pairing_prompt(state->dpy, name, ids[i]);
                }
            } else if (!has_pairing && td) {
                td->notified_pairing = 0;
            }

            snprintf(piece_static, sizeof(piece_static),
                     "%%{A1:%s -n %s -i %s -p:}%s%%{A}%s",
                     state->self_exe, name ? name : "", ids[i], icon_only(-2, devtype), SEPARATOR);

            if (td) {
                td->known = 1;
                td->was_reachable = 0;
                td->was_trusted = 0;
            }
        }

        sb_append(&out, piece);
        free(piece_dyn);
        free(name);
        free(devtype);
    }

    if (count == 0 && SHOW_ICON_WHEN_NO_DEVICES) {
        char buf[64];
        snprintf(buf, sizeof(buf), "%%{F%s}%s%%{F-}", COLOR_NO_DEVICES, ICON_NO_DEVICES);
        sb_append(&out, buf);
    }

    size_t seplen = strlen(SEPARATOR);
    if (out.len >= seplen && count > 0) out.buf[out.len - seplen] = '\0';

    kdc_free_device_ids(ids, count);
    return out.buf;
}

static void json_append_escaped(strbuf *sb, const char *s) {
    sb_append(sb, "\"");
    for (const unsigned char *p = (const unsigned char *)s; *p; p++) {
        switch (*p) {
            case '"':  sb_append(sb, "\\\""); break;
            case '\\': sb_append(sb, "\\\\"); break;
            case '\n': sb_append(sb, "\\n"); break;
            case '\r': sb_append(sb, "\\r"); break;
            case '\t': sb_append(sb, "\\t"); break;
            default:
                if (*p < 0x20) {
                    char buf[8];
                    snprintf(buf, sizeof(buf), "\\u%04x", *p);
                    sb_append(sb, buf);
                } else {
                    char buf[2] = { (char)*p, '\0' };
                    sb_append(sb, buf);
                }
        }
    }
    sb_append(sb, "\"");
}

/* Same device data and the same transition-tracking/notification side
 * effects as render_module(), just formatted as JSON instead of
 * polybar markup. Kept as a separate pass over the devices (rather
 * than sharing a "collect" step with render_module()) for simplicity
 * -- only one of the two is ever called per process invocation
 * (controlled by -j/--json), so there's no risk of double-firing
 * notifications between them. */
char *render_module_json(RenderState *state) {
    int count = 0;
    char **ids = kdc_get_device_ids(&count);

    strbuf out;
    sb_init(&out);
    sb_append(&out, "[");

    for (int i = 0; i < count; i++) {
        char devpath[300];
        kdc_device_path(devpath, sizeof(devpath), ids[i]);

        char *name = NULL, *devtype = NULL;
        kdc_get_string(devpath, KDC_DEVICE_IFACE, "name", &name);
        kdc_get_string(devpath, KDC_DEVICE_IFACE, "type", &devtype);

        int reachable = 0, paired = 0;
        kdc_get_bool(devpath, KDC_DEVICE_IFACE, "isReachable", &reachable);
        kdc_is_paired(devpath, &paired);

        int battery = -1;
        int is_low = 0;
        int signal_bars = -1;
        int have_signal = 0;
        const char *state_str = "unpaired";

        TrackedDevice *td = find_or_create(state, ids[i]);

        if (reachable && paired) {
            char batpath[320];
            snprintf(batpath, sizeof(batpath), "%s/battery", devpath);
            kdc_get_int(batpath, KDC_BATTERY_IFACE, "charge", &battery);
            is_low = (LOW_BATTERY_THRESHOLD >= 0 && battery >= 0 && battery <= LOW_BATTERY_THRESHOLD);
            have_signal = kdc_get_signal_bars(devpath, &signal_bars);
            state_str = "connected";

            if (td) {
                if (td->known && !td->was_reachable) {
                    save_last_device(ids[i]);
                    if (NOTIFY_ON_CONNECT) {
                        char msg[256];
                        snprintf(msg, sizeof(msg), "%s connected", name ? name : ids[i]);
                        kdc_notify(NOTIFY_APP_NAME, msg);
                    }
                }
                if (NOTIFY_ON_LOW_BATTERY && is_low && !td->was_low_battery) {
                    char msg[256];
                    snprintf(msg, sizeof(msg), "%s battery at %d%%", name ? name : ids[i], battery);
                    kdc_notify("Low battery", msg);
                }
                td->was_low_battery = is_low;
                td->was_reachable = 1;
                td->was_trusted = 1;
                td->known = 1;
                td->notified_pairing = 0;
            }

        } else if (!reachable && paired) {
            state_str = "disconnected";
            if (td) {
                if (NOTIFY_ON_DISCONNECT && td->known && td->was_reachable) {
                    char msg[256];
                    snprintf(msg, sizeof(msg), "%s disconnected", name ? name : ids[i]);
                    kdc_notify(NOTIFY_APP_NAME, msg);
                }
                td->was_reachable = 0;
                td->was_trusted = 1;
                td->known = 1;
                td->was_low_battery = 0;
                td->notified_pairing = 0;
            }

        } else {
            state_str = "unpaired";
            int has_pairing = 0;
            kdc_get_bool(devpath, KDC_DEVICE_IFACE, "isPairRequestedByPeer", &has_pairing);
            if (has_pairing && td && !td->notified_pairing) {
                td->notified_pairing = 1;
                if (NOTIFY_ON_PAIR_REQUEST) {
                    char msg[256];
                    snprintf(msg, sizeof(msg), "%s wants to pair", name ? name : ids[i]);
                    kdc_notify("KDE Connect pairing request", msg);
                }
                if (state->dpy) {
                    action_pairing_prompt(state->dpy, name, ids[i]);
                }
            } else if (!has_pairing && td) {
                td->notified_pairing = 0;
            }
            if (td) {
                td->known = 1;
                td->was_reachable = 0;
                td->was_trusted = 0;
            }
        }

        if (i > 0) sb_append(&out, ",");
        sb_append(&out, "{\"id\":");
        json_append_escaped(&out, ids[i]);
        sb_append(&out, ",\"name\":");
        json_append_escaped(&out, name ? name : "");
        sb_append(&out, ",\"type\":");
        json_append_escaped(&out, devtype ? devtype : "");
        sb_append(&out, ",\"state\":");
        json_append_escaped(&out, state_str);

        char numbuf[80];
        snprintf(numbuf, sizeof(numbuf), ",\"reachable\":%s,\"paired\":%s",
                 reachable ? "true" : "false", paired ? "true" : "false");
        sb_append(&out, numbuf);

        if (battery >= 0) {
            snprintf(numbuf, sizeof(numbuf), ",\"battery\":%d,\"low_battery\":%s",
                     battery, is_low ? "true" : "false");
        } else {
            snprintf(numbuf, sizeof(numbuf), ",\"battery\":null,\"low_battery\":false");
        }
        sb_append(&out, numbuf);

        if (have_signal) {
            snprintf(numbuf, sizeof(numbuf), ",\"signal_bars\":%d", signal_bars);
        } else {
            snprintf(numbuf, sizeof(numbuf), ",\"signal_bars\":null");
        }
        sb_append(&out, numbuf);

        sb_append(&out, "}");

        free(name);
        free(devtype);
    }

    sb_append(&out, "]");
    kdc_free_device_ids(ids, count);
    return out.buf;
}
