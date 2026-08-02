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

void render_state_init(RenderState *state, Display *dpy, const char *self_exe, int show_battery) {
    state->devices = NULL;
    state->count = 0;
    state->dpy = dpy;
    state->self_exe = self_exe;
    state->show_battery = show_battery;
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

static const char *icon_for(int battery, const char *devtype, int show_percent) {
    static char buf[128];
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

    if (show_percent && battery >= 0) {
        snprintf(buf, sizeof(buf), "%%{F%s}%s %d%%{F-}", color, icon, battery);
    } else {
        snprintf(buf, sizeof(buf), "%%{F%s}%s%%{F-}", color, icon);
    }
    return buf;
}

/* Best-effort SIM signal strength via connectivity_report. Returns an
 * empty string if the device has no cellular subscription (e.g. a
 * tablet) or the plugin isn't available -- never fails loudly. */
static const char *signal_icon_for(const char *devpath) {
    if (!SHOW_SIGNAL_STRENGTH) return "";

    int bars = -1;
    if (!kdc_get_signal_bars(devpath, &bars)) return "";

    static const char *icons[] = { ICON_SIGNAL_0, ICON_SIGNAL_1, ICON_SIGNAL_2, ICON_SIGNAL_3, ICON_SIGNAL_4 };
    static char buf[64];
    snprintf(buf, sizeof(buf), "%s ", icons[bars]);
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
        char piece[1024];

        if (reachable && trusted) {
            char batpath[320];
            snprintf(batpath, sizeof(batpath), "%s/battery", devpath);
            int battery = -1;
            kdc_get_int(batpath, KDC_BATTERY_IFACE, "charge", &battery);

            int is_low = (LOW_BATTERY_THRESHOLD >= 0 && battery >= 0 && battery <= LOW_BATTERY_THRESHOLD);
            const char *low_prefix = is_low ? ICON_LOW_BATTERY : "";
            const char *signal_prefix = signal_icon_for(devpath);

            snprintf(piece, sizeof(piece),
                     "%%{A1:%s -n '%s' -i %s -m:}%s%s%s%%{A}%s",
                     state->self_exe, name ? name : "", ids[i],
                     low_prefix, signal_prefix, icon_for(battery, devtype, state->show_battery), SEPARATOR);

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
            snprintf(piece, sizeof(piece), "%s%s", icon_for(-1, devtype, 0), SEPARATOR);

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

            snprintf(piece, sizeof(piece),
                     "%%{A1:%s -n %s -i %s -p:}%s%%{A}%s",
                     state->self_exe, name ? name : "", ids[i], icon_for(-2, devtype, 0), SEPARATOR);

            if (td) {
                td->known = 1;
                td->was_reachable = 0;
                td->was_trusted = 0;
            }
        }

        sb_append(&out, piece);
        free(name);
        free(devtype);
    }

    size_t seplen = strlen(SEPARATOR);
    if (out.len >= seplen) out.buf[out.len - seplen] = '\0';

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
