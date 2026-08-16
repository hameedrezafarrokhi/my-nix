#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <X11/Xlib.h>

#include "device.h"
#include "actions.h"
#include "daemon.h"
#include "render.h"
#include "state_file.h"
#include "config.h"

enum { OPT_GENERIC_MENU = 300, OPT_AT_POINTER, OPT_X, OPT_Y };

static void usage(const char *prog) {
    fprintf(stderr,
        "Usage:\n"
        "  %s --daemon [-j]                run persistent daemon (polybar tail=true)\n"
        "  %s -d [-j]                       print module text once and exit\n"
        "  %s -m [-i ID] [pos. opts]        open a device's action menu\n"
        "                                     (uses the most recently clicked device\n"
        "                                     if -i is omitted)\n"
        "  %s --generic-menu [pos. opts]    open the non-device menu (Mount ISO, etc)\n"
        "\n"
        "Position overrides for -m/--generic-menu (default: config.h\n"
        "MENU_POSITION_AT_POINTER / MENU_FIXED_X / MENU_FIXED_Y):\n"
        "  --at-pointer     force opening at the current pointer position\n"
        "  --x N            open at this fixed X coordinate\n"
        "  --y N            open at this fixed Y coordinate\n",
        prog, prog, prog, prog);
}

static void resolve_position(Display *dpy, int force_pointer, int has_x, int x_val,
                              int has_y, int y_val, int *out_x, int *out_y) {
    int use_pointer = force_pointer || (MENU_POSITION_AT_POINTER && !has_x && !has_y);
    if (use_pointer && dpy) {
        Window root = DefaultRootWindow(dpy);
        Window r, c; int rx = 0, ry = 0, wx = 0, wy = 0; unsigned int mask = 0;
        if (XQueryPointer(dpy, root, &r, &c, &rx, &ry, &wx, &wy, &mask)) {
            *out_x = rx; *out_y = ry; return;
        }
    }
    *out_x = has_x ? x_val : MENU_FIXED_X;
    *out_y = has_y ? y_val : MENU_FIXED_Y;
}

int main(int argc, char *argv[]) {
    int opt_daemon = 0, opt_once = 0, opt_menu = 0, opt_generic_menu = 0, opt_json = 0;
    int has_x = 0, has_y = 0, x_val = 0, y_val = 0, force_pointer = 0;
    const char *dev_id = NULL;

    static struct option long_opts[] = {
        {"daemon",        no_argument,       0, 'D'},
        {"json",          no_argument,       0, 'j'},
        {"generic-menu",  no_argument,       0, OPT_GENERIC_MENU},
        {"at-pointer",    no_argument,       0, OPT_AT_POINTER},
        {"x",             required_argument, 0, OPT_X},
        {"y",             required_argument, 0, OPT_Y},
        {0, 0, 0, 0}
    };

    int c;
    while ((c = getopt_long(argc, argv, "dji:m", long_opts, NULL)) != -1) {
        switch (c) {
            case 'D': opt_daemon = 1; break;
            case 'd': opt_once = 1; break;
            case 'j': opt_json = 1; break;
            case 'i': dev_id = optarg; break;
            case 'm': opt_menu = 1; break;
            case OPT_GENERIC_MENU: opt_generic_menu = 1; break;
            case OPT_AT_POINTER: force_pointer = 1; break;
            case OPT_X: has_x = 1; x_val = atoi(optarg); break;
            case OPT_Y: has_y = 1; y_val = atoi(optarg); break;
            default: break;
        }
    }

    if (!opt_daemon && !opt_once && !opt_menu && !opt_generic_menu) {
        usage(argv[0]);
        return 1;
    }

    Display *dpy = XOpenDisplay(NULL);
    if (!dpy && (opt_menu || opt_generic_menu)) {
        fprintf(stderr, "polybar-udisks: cannot open X display\n");
        return 1;
    }

    int rc = 0;

    if (opt_daemon) {
        rc = daemon_run(opt_json);
    } else if (opt_once) {
        DeviceList list = { NULL, 0 };
        device_list_build(&list);
        if (opt_json) render_json(&list);
        else render_bar(&list);
        device_list_free(&list);
    } else if (opt_menu) {
        DeviceList list = { NULL, 0 };
        device_list_build(&list);

        char *fallback = NULL;
        const char *id = dev_id;
        if (!id) {
            fallback = load_last_device();
            id = fallback;
        }

        Device *d = id ? device_list_find(&list, id) : NULL;
        if (!d && list.count == 1) d = &list.items[0]; /* only one device -- unambiguous even with no -i */

        if (d) {
            int x, y;
            resolve_position(dpy, force_pointer, has_x, x_val, has_y, y_val, &x, &y);
            action_open_device_menu(dpy, x, y, d, &list);
        } else {
            fprintf(stderr, "polybar-udisks: no device to show a menu for "
                             "(pass -i ID, or click a device segment so one is remembered)\n");
            rc = 1;
        }

        free(fallback);
        device_list_free(&list);
    } else if (opt_generic_menu) {
        DeviceList list = { NULL, 0 };
        device_list_build(&list);
        int x, y;
        resolve_position(dpy, force_pointer, has_x, x_val, has_y, y_val, &x, &y);
        action_open_generic_menu(dpy, x, y, &list);
        device_list_free(&list);
    }

    if (dpy) XCloseDisplay(dpy);
    return rc;
}
