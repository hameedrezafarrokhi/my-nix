#include "wmclass.h"
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Display *dpy = NULL;
static Atom net_wm_name_atom;
static Atom utf8_string_atom;

static int x_error_handler(Display *d, XErrorEvent *e) {
    (void)d;
    /* Windows routinely vanish between the bspwm event firing and us
     * querying X for its class/title (e.g. node_remove, or a very
     * short-lived window, or node_focus events trailing a window that's
     * already closing). BadWindow here is the normal/expected outcome of
     * that race, not a real problem -- happens constantly under
     * focus_follows_pointer, so don't spam the log for it. Anything else
     * is worth knowing about. */
    if (e->error_code == BadWindow) return 0;

    char msg[128];
    XGetErrorText(dpy, e->error_code, msg, sizeof(msg));
    fprintf(stderr, "bspwm-sounds: X error (ignored): %s (request %d, resource 0x%lx)\n",
            msg, e->request_code, e->resourceid);
    return 0;
}

int wm_init(void) {
    dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "bspwm-sounds: warning: could not open X display, "
                        "class/title-based rules will be skipped\n");
        return -1;
    }
    XSetErrorHandler(x_error_handler);
    net_wm_name_atom = XInternAtom(dpy, "_NET_WM_NAME", False);
    utf8_string_atom = XInternAtom(dpy, "UTF8_STRING", False);
    return 0;
}

int wm_get_class(unsigned long window_id, char *instance_out, int inst_sz, char *class_out, int class_sz) {
    if (!dpy) return -1;
    if (instance_out && inst_sz > 0) instance_out[0] = '\0';
    if (class_out && class_sz > 0) class_out[0] = '\0';

    XClassHint hint;
    memset(&hint, 0, sizeof(hint));
    /* XGetClassHint returns 0 on failure (e.g. window vanished already) */
    if (XGetClassHint(dpy, (Window)window_id, &hint) == 0) {
        return -1;
    }
    if (hint.res_name) {
        if (instance_out) snprintf(instance_out, inst_sz, "%s", hint.res_name);
        XFree(hint.res_name);
    }
    if (hint.res_class) {
        if (class_out) snprintf(class_out, class_sz, "%s", hint.res_class);
        XFree(hint.res_class);
    }
    return 0;
}

int wm_get_title(unsigned long window_id, char *title_out, int title_sz) {
    if (!dpy) return -1;
    if (title_sz > 0) title_out[0] = '\0';

    Atom actual_type;
    int actual_format;
    unsigned long nitems, bytes_after;
    unsigned char *prop = NULL;

    if (XGetWindowProperty(dpy, (Window)window_id, net_wm_name_atom, 0, 1024, False,
                            utf8_string_atom, &actual_type, &actual_format,
                            &nitems, &bytes_after, &prop) == Success && prop) {
        if (actual_type == utf8_string_atom && nitems > 0) {
            snprintf(title_out, title_sz, "%.*s", (int)nitems, (char *)prop);
            XFree(prop);
            return 0;
        }
        XFree(prop);
    }

    /* Fallback to legacy WM_NAME */
    char *name = NULL;
    if (XFetchName(dpy, (Window)window_id, &name) && name) {
        snprintf(title_out, title_sz, "%s", name);
        XFree(name);
        return 0;
    }

    return -1;
}

void wm_shutdown(void) {
    if (dpy) {
        XCloseDisplay(dpy);
        dpy = NULL;
    }
}
