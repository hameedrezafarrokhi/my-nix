#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <X11/Xlib.h>

#include "dbus_client.h"
#include "render.h"
#include "actions.h"
#include "daemon.h"
#include "config.h"

/* Long-only option codes for the direct single-action flags, kept
 * well clear of any ASCII letter to avoid any risk of colliding with
 * a short option now or in the future. */
enum {
    OPT_PING = 300,
    OPT_FIND,
    OPT_SEND_FILE,
    OPT_BROWSE,
    OPT_CLIPBOARD,
    OPT_PAIR,
    OPT_UNPAIR,
    OPT_MESSAGES,
    OPT_OPEN_APP,
    OPT_SHOW_NAME,
};

static const char *resolve_self_exe(void) {
    static char path[4096];
    ssize_t n = readlink("/proc/self/exe", path, sizeof(path) - 1);
    if (n > 0) {
        path[n] = '\0';
        return path;
    }
    return "polybar-kdeconnect";
}

static void usage(const char *prog) {
    fprintf(stderr,
        "Usage:\n"
        "  %s --daemon [-b] [-j] [--show-name]     run persistent daemon (use with polybar tail=true)\n"
        "                                            -b/--battery-percent: also print numeric battery %%\n"
        "                                            --show-name: also print device name (between icon and %%)\n"
        "                                            -j/--json: print JSON instead of polybar markup\n"
        "  %s -d [-b] [-j] [--show-name]            print module text once and exit\n"
        "  %s -m [-n NAME -i ID] [pos. opts]       device action menu (auto-picks the connected\n"
        "                                            device if -i is omitted; see README)\n"
        "  %s -n NAME -i ID -p [pos. opts]         same as -m (kept for compatibility)\n"
        "\n"
        "Direct single-action flags (skip the menu entirely; same device\n"
        "auto-resolution as -m when -i/-n are omitted):\n"
        "  --ping  --find-device  --send-file [pos. opts]  --browse-files\n"
        "  --send-clipboard  --pair  --unpair  --messages  --open-app\n"
        "\n"
        "Position overrides for -m/-p/--send-file (default: config.h\n"
        "MENU_POSITION_AT_POINTER / MENU_FIXED_X / MENU_FIXED_Y):\n"
        "  --at-pointer     force opening at the current pointer position\n"
        "  --x N            open at this fixed X coordinate\n"
        "  --y N            open at this fixed Y coordinate\n",
        prog, prog, prog, prog);
}

int main(int argc, char *argv[]) {
    int opt_daemon = 0, opt_once = 0, opt_menu = 0, opt_pmenu = 0;
    int opt_battery_percent = SHOW_BATTERY_PERCENT_DEFAULT;
    int opt_show_name = SHOW_DEVICE_NAME_DEFAULT;
    int opt_json = 0;
    int opt_ping = 0, opt_find = 0, opt_send_file = 0, opt_browse = 0;
    int opt_clipboard = 0, opt_pair = 0, opt_unpair = 0, opt_messages = 0, opt_open_app = 0;
    const char *dev_id = NULL, *dev_name = NULL;

    MenuPos pos;
    pos.has_x = 0;
    pos.has_y = 0;
    pos.x = 0;
    pos.y = 0;
    pos.force_pointer = 0;

    /* Using getopt_long (not a hand-rolled "--daemon" pre-scan plus
     * plain getopt) is deliberate: plain getopt() doesn't understand
     * "--" prefixed tokens and will scan them character-by-character
     * as clustered short options. That previously caused "--daemon"
     * to be misparsed as -d, -m, and -n (with the *next* argv token
     * silently consumed as -n's argument!), which is exactly why
     * `--daemon -b` was swallowing the -b flag. getopt_long matches
     * "--foo" tokens against long_opts properly and doesn't have this
     * failure mode. */
    static struct option long_opts[] = {
        {"daemon",          no_argument,       0, 'D'},
        {"battery-percent", no_argument,       0, 'b'},
        {"json",            no_argument,       0, 'j'},
        {"at-pointer",      no_argument,       0, 'P'},
        {"x",               required_argument, 0, 'X'},
        {"y",               required_argument, 0, 'Y'},
        {"ping",            no_argument,       0, OPT_PING},
        {"find-device",     no_argument,       0, OPT_FIND},
        {"send-file",       no_argument,       0, OPT_SEND_FILE},
        {"browse-files",    no_argument,       0, OPT_BROWSE},
        {"send-clipboard",  no_argument,       0, OPT_CLIPBOARD},
        {"pair",            no_argument,       0, OPT_PAIR},
        {"unpair",          no_argument,       0, OPT_UNPAIR},
        {"messages",        no_argument,       0, OPT_MESSAGES},
        {"open-app",        no_argument,       0, OPT_OPEN_APP},
        {"show-name",       no_argument,       0, OPT_SHOW_NAME},
        {0, 0, 0, 0}
    };

    int c;
    while ((c = getopt_long(argc, argv, "dbji:n:mp", long_opts, NULL)) != -1) {
        switch (c) {
            case 'D': opt_daemon = 1; break;
            case 'd': opt_once = 1; break;
            case 'b': opt_battery_percent = 1; break;
            case 'j': opt_json = 1; break;
            case 'i': dev_id = optarg; break;
            case 'n': dev_name = optarg; break;
            case 'm': opt_menu = 1; break;
            case 'p': opt_pmenu = 1; break;
            case 'P': pos.force_pointer = 1; break;
            case 'X': pos.has_x = 1; pos.x = atoi(optarg); break;
            case 'Y': pos.has_y = 1; pos.y = atoi(optarg); break;
            case OPT_PING: opt_ping = 1; break;
            case OPT_FIND: opt_find = 1; break;
            case OPT_SEND_FILE: opt_send_file = 1; break;
            case OPT_BROWSE: opt_browse = 1; break;
            case OPT_CLIPBOARD: opt_clipboard = 1; break;
            case OPT_PAIR: opt_pair = 1; break;
            case OPT_UNPAIR: opt_unpair = 1; break;
            case OPT_MESSAGES: opt_messages = 1; break;
            case OPT_OPEN_APP: opt_open_app = 1; break;
            case OPT_SHOW_NAME: opt_show_name = 1; break;
            default: break;
        }
    }

    int any_action = opt_daemon || opt_once || opt_menu || opt_pmenu ||
                      opt_ping || opt_find || opt_send_file || opt_browse ||
                      opt_clipboard || opt_pair || opt_unpair || opt_messages || opt_open_app;

    if (!any_action) {
        usage(argv[0]);
        return 1;
    }

    const char *self_exe = resolve_self_exe();

    /* X is needed for the daemon (to pop the incoming-pairing prompt),
     * the action menu, the pair-device menu, and --send-file (the
     * file picker). It's optional for everything else: if unavailable,
     * pure D-Bus actions (ping, find, browse, clipboard, pair, unpair)
     * still work, and -d just skips the pairing-request popup and
     * still prints the module text. */
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy && (opt_menu || opt_pmenu || opt_send_file)) {
        fprintf(stderr, "polybar-kdeconnect: cannot open X display\n");
        return 1;
    }

    int rc = 0;

    if (opt_daemon) {
        rc = daemon_run(dpy, self_exe, opt_battery_percent, opt_show_name, opt_json);
    } else if (opt_once) {
        RenderState state;
        render_state_init(&state, dpy, self_exe, opt_battery_percent, opt_show_name);
        char *out = opt_json ? render_module_json(&state) : render_module(&state);
        printf("%s\n", out);
        free(out);
        render_state_free(&state);
    } else if (opt_menu) {
        action_show_menu(dpy, dev_id, dev_name, &pos);
    } else if (opt_pmenu) {
        action_show_pmenu(dpy, dev_id, dev_name, &pos);
    } else if (opt_ping) {
        action_ping(dpy, dev_id, dev_name);
    } else if (opt_find) {
        action_find_device(dpy, dev_id, dev_name);
    } else if (opt_send_file) {
        action_send_file(dpy, dev_id, dev_name, &pos);
    } else if (opt_browse) {
        action_browse_files(dpy, dev_id, dev_name);
    } else if (opt_clipboard) {
        action_send_clipboard(dpy, dev_id, dev_name);
    } else if (opt_pair) {
        action_pair(dpy, dev_id, dev_name);
    } else if (opt_unpair) {
        action_unpair(dpy, dev_id, dev_name);
    } else if (opt_messages) {
        action_messages();
    } else if (opt_open_app) {
        action_open_app();
    }

    if (dpy) XCloseDisplay(dpy);
    return rc;
}
