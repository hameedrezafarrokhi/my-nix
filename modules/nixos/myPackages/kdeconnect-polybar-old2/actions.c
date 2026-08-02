#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <X11/Xlib.h>

#include "actions.h"
#include "xmenu.h"
#include "filepicker.h"
#include "dbus_client.h"
#include "notify.h"
#include "state_file.h"
#include "config.h"

enum {
    ACT_PING = 1,
    ACT_FIND,
    ACT_SEND_FILE,
    ACT_BROWSE,
    ACT_CLIPBOARD,
    ACT_SMS,
    ACT_PAIR,
    ACT_UNPAIR,
    ACT_OPEN_APP,
};

/* Ids >= these bases are dynamic submenu entries; the offset within
 * each identifies which connected device / custom entry. */
#define ACT_SWITCH_BASE 1000
#define ACT_CUSTOM_BASE 2000

static void pointer_position(Display *dpy, int *x, int *y) {
    Window root = DefaultRootWindow(dpy);
    Window ret_root, child;
    int root_x, root_y, win_x, win_y;
    unsigned int mask;
    XQueryPointer(dpy, root, &ret_root, &child, &root_x, &root_y, &win_x, &win_y, &mask);
    *x = root_x;
    *y = root_y;
}

/* Resolves where a menu should open: CLI override (pos) if given,
 * else config.h's MENU_POSITION_AT_POINTER / MENU_FIXED_X/Y. */
static void resolve_position(Display *dpy, const MenuPos *pos, int *x, int *y) {
    int use_pointer = MENU_POSITION_AT_POINTER;
    int fx = MENU_FIXED_X, fy = MENU_FIXED_Y;

    if (pos) {
        if (pos->force_pointer) {
            use_pointer = 1;
        } else if (pos->has_x || pos->has_y) {
            use_pointer = 0;
            if (pos->has_x) fx = pos->x;
            if (pos->has_y) fy = pos->y;
        }
    }

    if (use_pointer) {
        pointer_position(dpy, x, y);
    } else {
        *x = fx;
        *y = fy;
    }
}

/* Launches an external GUI app (kdeconnect-sms, the KDE Connect app
 * itself) detached from us, without waiting on it -- best effort,
 * silent on failure, same spirit as a polybar click handler. */
static void spawn_detached(const char *bin) {
    pid_t pid = fork();
    if (pid == 0) {
        setsid();
        char *argv[] = { (char *)bin, NULL };
        execvp(bin, argv);
        _exit(127);
    }
    /* parent: intentionally not waiting -- the app runs on its own */
}

static char *fetch_device_name(const char *id) {
    char path[300];
    kdc_device_path(path, sizeof(path), id);
    char *name = NULL;
    kdc_get_string(path, KDC_DEVICE_IFACE, "name", &name);
    return name;
}

/* Initiates pairing and, best-effort, surfaces the verification key
 * KDE Connect shows on the phone so it can be compared without
 * switching to kdeconnect's own UI. The key may not be computed the
 * instant requestPairing() returns, so we give the daemon a moment
 * before asking -- not a guarantee, just a pragmatic improvement over
 * "sometimes the notification is just empty and we give up". */
static void request_pairing_and_notify_key(const char *devpath, const char *dev_name) {
    kdc_action(devpath, KDC_DEVICE_IFACE, "requestPairing", NULL);

    usleep(400000); /* 400ms, best-effort grace period for the key to become available */

    char *key = NULL;
    if (kdc_get_verification_key(devpath, &key) && key && key[0] != '\0') {
        char summary[160];
        snprintf(summary, sizeof(summary), "Pairing with %s", dev_name ? dev_name : "device");
        kdc_notify(summary, key);
    }
    free(key);
}

/* Resolves which device `-m` should act on when invoked with no -i/-n
 * (e.g. from a keybinding rather than a bar click). See actions.h.
 * Precedence: explicit CLI args (handled by the caller) > config.h
 * DEFAULT_DEVICE_ID > live auto-detection (last-connected / only-one). */
static void resolve_default_device(char **out_id, char **out_name) {
    *out_id = NULL;
    *out_name = NULL;

    if (DEFAULT_DEVICE_ID[0] != '\0') {
        *out_id = strdup(DEFAULT_DEVICE_ID);
        *out_name = (DEFAULT_DEVICE_NAME[0] != '\0') ? strdup(DEFAULT_DEVICE_NAME) : fetch_device_name(DEFAULT_DEVICE_ID);
        return;
    }

    int count = 0;
    char **ids = kdc_get_connected_device_ids(&count);
    if (count == 0) {
        kdc_free_device_ids(ids, count);
        return;
    }

    const char *chosen = ids[0];
    if (count > 1) {
        char *last = load_last_device();
        if (last) {
            for (int i = 0; i < count; i++) {
                if (strcmp(ids[i], last) == 0) {
                    chosen = ids[i];
                    break;
                }
            }
            free(last);
        }
    }

    *out_id = strdup(chosen);
    *out_name = fetch_device_name(chosen);
    kdc_free_device_ids(ids, count);
}

void action_show_menu(Display *dpy, const char *dev_id_in, const char *dev_name_in, const MenuPos *pos) {
    int x, y;
    resolve_position(dpy, pos, &x, &y);

    char *resolved_id = NULL, *resolved_name = NULL;
    const char *dev_id = dev_id_in;
    const char *dev_name = dev_name_in;

    if (!dev_id) {
        resolve_default_device(&resolved_id, &resolved_name);
        if (!resolved_id) {
            MenuItem none[] = { { "No devices connected", 0, 0, NULL, 0 } };
            xmenu_show(dpy, x, y, none, 1, NULL);
            return;
        }
        dev_id = resolved_id;
        dev_name = resolved_name;
    }

    char devpath[300];
    kdc_device_path(devpath, sizeof(devpath), dev_id);

    int paired = 0;
    kdc_is_paired(devpath, &paired);

    /* Unpaired device: skip the normal action list entirely (it's
     * meaningless before pairing) and go straight to a pairing
     * prompt. This is what makes a separate -p invocation
     * unnecessary -- -m now does the right thing either way. */
    if (!paired) {
        char header[192];
        snprintf(header, sizeof(header), "%s", dev_name ? dev_name : "New device");

        MenuItem items[] = {
            { header, 0, 0, NULL, 0 },
            { NULL, 0, 0, NULL, 0 },
            { "Pair Device", ACT_PAIR, 1, NULL, 0 },
        };

        int id = xmenu_show(dpy, x, y, items, 3, NULL);
        if (id == ACT_PAIR) {
            request_pairing_and_notify_key(devpath, dev_name);
        }

        free(resolved_id);
        free(resolved_name);
        return;
    }

    char batpath[340];
    snprintf(batpath, sizeof(batpath), "%s/battery", devpath);
    int battery = -1;
    kdc_get_int(batpath, KDC_BATTERY_IFACE, "charge", &battery);

    int signal_bars = -1;
    int have_signal = SHOW_SIGNAL_STRENGTH && kdc_get_signal_bars(devpath, &signal_bars);

    char header_main[192];
    if (battery >= 0) {
        snprintf(header_main, sizeof(header_main), "%s \u2014 Battery: %d%%",
                 dev_name ? dev_name : "Device", battery);
    } else {
        snprintf(header_main, sizeof(header_main), "%s", dev_name ? dev_name : "Device");
    }

    char header_signal[64];
    if (have_signal) {
        snprintf(header_signal, sizeof(header_signal), "Signal: %d/4", signal_bars);
    }

    /* other currently connected devices, for an always-available
     * "Switch Device" submenu */
    int conn_count = 0;
    char **conn_ids = SHOW_MENU_SWITCH_DEVICE ? kdc_get_connected_device_ids(&conn_count) : NULL;
    int other_count = 0;
    for (int i = 0; i < conn_count; i++) {
        if (strcmp(conn_ids[i], dev_id) != 0) other_count++;
    }

    MenuItem *switch_sub = NULL;
    char **switch_labels = NULL;
    char **switch_ids = NULL;
    if (other_count > 0) {
        switch_sub = calloc((size_t)other_count, sizeof(MenuItem));
        switch_labels = calloc((size_t)other_count, sizeof(char *));
        switch_ids = calloc((size_t)other_count, sizeof(char *));
        if (switch_sub && switch_labels && switch_ids) {
            int k = 0;
            for (int i = 0; i < conn_count; i++) {
                if (strcmp(conn_ids[i], dev_id) == 0) continue;
                switch_labels[k] = fetch_device_name(conn_ids[i]);
                if (!switch_labels[k]) switch_labels[k] = strdup(conn_ids[i]);
                switch_ids[k] = strdup(conn_ids[i]);
                switch_sub[k].label = switch_labels[k];
                switch_sub[k].id = ACT_SWITCH_BASE + k;
                switch_sub[k].enabled = 1;
                k++;
            }
            other_count = k;
        } else {
            free(switch_sub); switch_sub = NULL;
            free(switch_labels); switch_labels = NULL;
            free(switch_ids); switch_ids = NULL;
            other_count = 0;
        }
    }

    int custom_count = 0;
    if (SHOW_MENU_CUSTOM_ENTRIES) {
        while (CUSTOM_MENU_ENTRIES[custom_count].command != NULL) custom_count++;
    }

    int max_items = 3 /* header row + signal row + sep */
                  + 9 /* ping/find/sendfile/browse/clipboard/sms/switch/pair/unpair/openapp -- generous */
                  + 3 /* separators between groups */
                  + (custom_count > 0 ? custom_count + 1 : 0);
    MenuItem *items = calloc((size_t)max_items, sizeof(MenuItem));
    if (!items) {
        free(switch_sub); free(switch_labels); free(switch_ids);
        kdc_free_device_ids(conn_ids, conn_count);
        free(resolved_id); free(resolved_name);
        return;
    }

    int ni = 0;
    items[ni++] = (MenuItem){ header_main, 0, 0, NULL, 0 };
    if (have_signal) items[ni++] = (MenuItem){ header_signal, 0, 0, NULL, 0 };
    items[ni++] = (MenuItem){ NULL, 0, 0, NULL, 0 };
    if (SHOW_MENU_PING)         items[ni++] = (MenuItem){ "Ping", ACT_PING, 1, NULL, 0 };
    if (SHOW_MENU_FIND_DEVICE)  items[ni++] = (MenuItem){ "Find Device", ACT_FIND, 1, NULL, 0 };
    if (SHOW_MENU_SEND_FILE)    items[ni++] = (MenuItem){ "Send File", ACT_SEND_FILE, 1, NULL, 0 };
    if (SHOW_MENU_BROWSE_FILES) items[ni++] = (MenuItem){ "Browse Files", ACT_BROWSE, 1, NULL, 0 };
    if (SHOW_MENU_CLIPBOARD)    items[ni++] = (MenuItem){ "Send Clipboard", ACT_CLIPBOARD, 1, NULL, 0 };
    if (SHOW_MENU_MESSAGES)     items[ni++] = (MenuItem){ "Messages", ACT_SMS, 1, NULL, 0 };
    if (SHOW_MENU_SWITCH_DEVICE && other_count > 0) {
        items[ni++] = (MenuItem){ "Switch Device", 0, 1, switch_sub, other_count };
    }
    if (SHOW_MENU_PAIR_DEVICE) items[ni++] = (MenuItem){ "Pair Device", ACT_PAIR, 1, NULL, 0 };
    items[ni++] = (MenuItem){ NULL, 0, 0, NULL, 0 };
    if (SHOW_MENU_UNPAIR)   items[ni++] = (MenuItem){ "Unpair", ACT_UNPAIR, 1, NULL, 0 };
    if (SHOW_MENU_OPEN_APP) items[ni++] = (MenuItem){ "Open KDE Connect", ACT_OPEN_APP, 1, NULL, 0 };

    if (custom_count > 0) {
        items[ni++] = (MenuItem){ NULL, 0, 0, NULL, 0 };
        for (int i = 0; i < custom_count; i++) {
            items[ni].label = CUSTOM_MENU_ENTRIES[i].label;
            items[ni].id = ACT_CUSTOM_BASE + i;
            items[ni].enabled = 1;
            items[ni].submenu = NULL;
            items[ni].submenu_count = 0;
            ni++;
        }
    }

    int id = xmenu_show(dpy, x, y, items, ni, NULL);
    free(items);

    if (id >= ACT_CUSTOM_BASE) {
        int k = id - ACT_CUSTOM_BASE;
        if (k >= 0 && k < custom_count) {
            spawn_detached(CUSTOM_MENU_ENTRIES[k].command);
        }
    } else if (id >= ACT_SWITCH_BASE) {
        int k = id - ACT_SWITCH_BASE;
        if (k >= 0 && k < other_count) {
            char *target_id = strdup(switch_ids[k]);
            for (int i = 0; i < other_count; i++) {
                free(switch_labels[i]);
                free(switch_ids[i]);
            }
            free(switch_labels);
            free(switch_ids);
            free(switch_sub);
            kdc_free_device_ids(conn_ids, conn_count);
            free(resolved_id);
            free(resolved_name);

            action_show_menu(dpy, target_id, NULL, pos);
            free(target_id);
            return;
        }
    } else {
        char sub[340];
        switch (id) {
        case ACT_PING:
            snprintf(sub, sizeof(sub), "%s/ping", devpath);
            kdc_action(sub, KDC_PING_IFACE, "sendPing", NULL);
            break;

        case ACT_FIND:
            snprintf(sub, sizeof(sub), "%s/findmyphone", devpath);
            kdc_action(sub, KDC_FINDMYPHONE_IFACE, "ring", NULL);
            break;

        case ACT_SEND_FILE: {
            int fc = 0;
            char **files = filepicker_choose(dpy, x, y, 1, &fc);
            if (files) {
                snprintf(sub, sizeof(sub), "%s/share", devpath);
                for (int i = 0; i < fc; i++) {
                    char url[4200];
                    snprintf(url, sizeof(url), "file://%s", files[i]);
                    kdc_action(sub, KDC_SHARE_IFACE, "shareUrl", url);
                    free(files[i]);
                }
                free(files);
            }
            break;
        }

        case ACT_BROWSE: {
            snprintf(sub, sizeof(sub), "%s/sftp", devpath);
            int mounted = 0;
            kdc_get_bool(sub, KDC_SFTP_IFACE, "isMounted", &mounted);
            if (!mounted) kdc_action(sub, KDC_SFTP_IFACE, "mount", NULL);
            kdc_action(sub, KDC_SFTP_IFACE, "startBrowsing", NULL);
            break;
        }

        case ACT_CLIPBOARD:
            snprintf(sub, sizeof(sub), "%s/clipboard", devpath);
            kdc_action(sub, KDC_CLIPBOARD_IFACE, "sendClipboard", NULL);
            break;

        case ACT_SMS:
            spawn_detached(SMS_APP_BIN);
            break;

        case ACT_PAIR:
            request_pairing_and_notify_key(devpath, dev_name);
            break;

        case ACT_UNPAIR:
            kdc_action(devpath, KDC_DEVICE_IFACE, "unpair", NULL);
            break;

        case ACT_OPEN_APP:
            spawn_detached(KDECONNECT_APP_BIN);
            break;

        default:
            break;
        }
    }

    if (switch_sub) {
        for (int i = 0; i < other_count; i++) {
            free(switch_labels[i]);
            free(switch_ids[i]);
        }
        free(switch_labels);
        free(switch_ids);
        free(switch_sub);
    }
    kdc_free_device_ids(conn_ids, conn_count);
    free(resolved_id);
    free(resolved_name);
}

void action_show_pmenu(Display *dpy, const char *dev_id, const char *dev_name, const MenuPos *pos) {
    /* -m now handles the unpaired case correctly on its own -- see
     * actions.h. Kept as a thin wrapper for backward compatibility. */
    action_show_menu(dpy, dev_id, dev_name, pos);
}

void action_pairing_prompt(Display *dpy, const char *dev_name, const char *dev_id) {
    char header[256];
    snprintf(header, sizeof(header), "%s wants to pair", dev_name ? dev_name : "Device");

    MenuItem items[] = {
        { header,  0, 0, NULL, 0 },
        { NULL,    0, 0, NULL, 0 },
        { "Accept", 1, 1, NULL, 0 },
        { "Reject", 2, 1, NULL, 0 },
    };

    int x, y;
    resolve_position(dpy, NULL, &x, &y);

    int id = xmenu_show(dpy, x, y, items, 4, NULL);

    char devpath[300];
    kdc_device_path(devpath, sizeof(devpath), dev_id);

    /* Mirrors the original script's behavior: anything other than an
     * explicit Accept (including Escape/click-away) cancels, so a
     * pairing request never sits ignored indefinitely. */
    if (id == 1) {
        kdc_action(devpath, KDC_DEVICE_IFACE, "acceptPairing", NULL);
    } else {
        kdc_action(devpath, KDC_DEVICE_IFACE, "cancelPairing", NULL);
    }
}

/* ------------------------------------------------------------------
 * Direct single-action entry points (CLI flags like --ping, --pair,
 * etc, for running one action without opening the menu). Deliberately
 * kept as their own small, self-contained implementations rather than
 * refactored to share code with action_show_menu()'s switch cases --
 * action_show_menu is already working and tested, and threading these
 * through it would risk changing its behavior for no real benefit.
 * A little duplication here is the safer trade.
 * ------------------------------------------------------------------ */

typedef struct {
    char *resolved_id;   /* malloc'd only if auto-resolution was needed */
    char *resolved_name; /* malloc'd only if auto-resolution was needed */
    const char *id;
    const char *name;
    char devpath[300];
} ResolvedDevice;

/* Returns 1 with `rd` fully populated on success. Returns 0 if no
 * device could be resolved -- when `dpy` is non-NULL, also pops the
 * same brief "No devices connected" notice action_show_menu shows. */
static int resolve_for_action(Display *dpy, const char *dev_id_in, const char *dev_name_in, ResolvedDevice *rd) {
    rd->resolved_id = NULL;
    rd->resolved_name = NULL;
    rd->id = dev_id_in;
    rd->name = dev_name_in;

    if (!rd->id) {
        resolve_default_device(&rd->resolved_id, &rd->resolved_name);
        if (!rd->resolved_id) {
            if (dpy) {
                MenuItem none[] = { { "No devices connected", 0, 0, NULL, 0 } };
                int x, y;
                resolve_position(dpy, NULL, &x, &y);
                xmenu_show(dpy, x, y, none, 1, NULL);
            }
            return 0;
        }
        rd->id = rd->resolved_id;
        rd->name = rd->resolved_name;
    }

    kdc_device_path(rd->devpath, sizeof(rd->devpath), rd->id);
    return 1;
}

static void resolved_device_free(ResolvedDevice *rd) {
    free(rd->resolved_id);
    free(rd->resolved_name);
}

void action_ping(Display *dpy, const char *dev_id, const char *dev_name) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;
    char sub[340];
    snprintf(sub, sizeof(sub), "%s/ping", rd.devpath);
    kdc_action(sub, KDC_PING_IFACE, "sendPing", NULL);
    resolved_device_free(&rd);
}

void action_find_device(Display *dpy, const char *dev_id, const char *dev_name) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;
    char sub[340];
    snprintf(sub, sizeof(sub), "%s/findmyphone", rd.devpath);
    kdc_action(sub, KDC_FINDMYPHONE_IFACE, "ring", NULL);
    resolved_device_free(&rd);
}

void action_send_file(Display *dpy, const char *dev_id, const char *dev_name, const MenuPos *pos) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;

    if (!dpy) {
        resolved_device_free(&rd);
        return; /* the file picker needs X */
    }

    int x, y;
    resolve_position(dpy, pos, &x, &y);

    int fc = 0;
    char **files = filepicker_choose(dpy, x, y, 1, &fc);
    if (files) {
        char sub[340];
        snprintf(sub, sizeof(sub), "%s/share", rd.devpath);
        for (int i = 0; i < fc; i++) {
            char url[4200];
            snprintf(url, sizeof(url), "file://%s", files[i]);
            kdc_action(sub, KDC_SHARE_IFACE, "shareUrl", url);
            free(files[i]);
        }
        free(files);
    }
    resolved_device_free(&rd);
}

void action_browse_files(Display *dpy, const char *dev_id, const char *dev_name) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;
    char sub[340];
    snprintf(sub, sizeof(sub), "%s/sftp", rd.devpath);
    int mounted = 0;
    kdc_get_bool(sub, KDC_SFTP_IFACE, "isMounted", &mounted);
    if (!mounted) kdc_action(sub, KDC_SFTP_IFACE, "mount", NULL);
    kdc_action(sub, KDC_SFTP_IFACE, "startBrowsing", NULL);
    resolved_device_free(&rd);
}

void action_send_clipboard(Display *dpy, const char *dev_id, const char *dev_name) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;
    char sub[340];
    snprintf(sub, sizeof(sub), "%s/clipboard", rd.devpath);
    kdc_action(sub, KDC_CLIPBOARD_IFACE, "sendClipboard", NULL);
    resolved_device_free(&rd);
}

void action_pair(Display *dpy, const char *dev_id, const char *dev_name) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;
    request_pairing_and_notify_key(rd.devpath, rd.name);
    resolved_device_free(&rd);
}

void action_unpair(Display *dpy, const char *dev_id, const char *dev_name) {
    ResolvedDevice rd;
    if (!resolve_for_action(dpy, dev_id, dev_name, &rd)) return;
    kdc_action(rd.devpath, KDC_DEVICE_IFACE, "unpair", NULL);
    resolved_device_free(&rd);
}

void action_messages(void) {
    spawn_detached(SMS_APP_BIN);
}

void action_open_app(void) {
    spawn_detached(KDECONNECT_APP_BIN);
}
