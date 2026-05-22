/*                         
__   _______      ___ __ ___
\ \ / / __\ \ /\ / / '_ ` _ \ 
 \ V /\__ \\ V  V /| | | | | |
  \_/ |___/ \_/\_/ |_| |_| |_|

*/

/* VSWM - Very Small Window Manager
 * VSWM - Very Simple Window Manager
 *
 * Thanks - TinyWM
 * Thanks - SOWM
*/

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "config.h"

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define win_size(W, gx, gy, gw, gh) XGetGeometry(dpy, W, &(Window){0}, gx, gy, gw, gh, &(unsigned int){0}, &(unsigned int){0})
#define ALL_WINDOWS            \
    win* t = 0, *w = win_list; \
    w && t != win_list->prev;  \
    t = w, w = w->next
static unsigned int running = 1;

static win* win_list = {0};
static win* active = {0};
static Window w_arr[5];
static Display* dpy;
static Window bar;
static Window bar_s;
static GC bar_gc;
XButtonEvent start;
static XEvent ev;

char i2msg[12];

void lll(char msg[]) {
    FILE* fp;
    fp = fopen("log.txt", "a");
    fprintf(fp, "[%ld] - %s \n", CurrentTime, msg);
    fclose(fp);
}

// OLD
void run(Display* dpy, XEvent ev, int arg) {
    // if (fork() == 0) {
    //     if (dpy) { close(ConnectionNumber(dpy)); }
    //     lll(a.c[0]);
    //     setsid();
    //     execvp((char*)a.c[0], (char**)a.c);
    // }
}

int error_handler(Display* dpy, XErrorEvent* ev) {
    //lll("[ ERROR ]");
    //FILE * fp = fopen("log.txt", "a");
    //fprintf(fp, "%d \n", ev->error_code);
    //fclose(fp);
    return 0;
}

void key_handler(Display* dpy, XEvent ev) {
    for (int i = 0; i < sizeof(keys) / sizeof(*keys); i++) {
        if ((keys[i].modifiers == ev.xkey.state) && (XKeysymToKeycode(dpy, XStringToKeysym(keys[i].key)) == ev.xkey.keycode)) { keys[i].function(dpy, ev, keys[i].arg); }
    }
}

void key_init(Display* dpy) {
    for (int i = 0; i < sizeof(keys) / sizeof(*keys); i++) { XGrabKey(dpy, XKeysymToKeycode(dpy, XStringToKeysym(keys[i].key)), keys[i].modifiers, DefaultRootWindow(dpy), True, GrabModeAsync, GrabModeAsync); }
}

/* Helpers */

void _win_add(Display* dpy, win* w) {
    if (DEBUG) { lll("_win_add"); }
    if (win_list) {
        win_list->prev->next = w;
        w->prev = win_list->prev;
        win_list->prev = w;
        w->next = win_list;
    } else {
        win_list = w;
        win_list->prev = win_list->next = win_list;
    }
}

void _win_del(Display* dpy, win* w) {
    if (DEBUG) { lll("_win_del"); }
    if (!win_list || !w) { return; }
    if (w->prev == w) { win_list = 0; }
    if (win_list == w) { win_list = w->next; }
    if (w->next) { w->next->prev = w->prev; }
    if (w->prev) { w->prev->next = w->next; }
    if (!win_list) { active = 0; }
}

void _restack(Display* dpy, win* w) {
    if (DEBUG) { lll("\t_restack"); }
    if (BAR_HEIGHT) {
        if (TITLEBAR_HEIGHT) {
            w_arr[0] = bar;
            w_arr[1] = bar_s;
            w_arr[2] = w->window;
            w_arr[3] = w->t;
            w_arr[4] = w->s;
            XRestackWindows(dpy, w_arr, 5);
            return;
        } else {
            w_arr[0] = bar;
            w_arr[1] = bar_s;
            w_arr[2] = w->window;
            w_arr[3] = w->s;
            XRestackWindows(dpy, w_arr, 4);
            return;
        }
    }
    if (TITLEBAR_HEIGHT) {
        w_arr[0] = w->window;
        w_arr[1] = w->t;
        w_arr[2] = w->s;
        XRestackWindows(dpy, w_arr, 3);
        return;
    } else {
        w_arr[0] = w->window;
        w_arr[1] = w->s;
        XRestackWindows(dpy, w_arr, 2);
        return;
    }
}

void _focus(Display* dpy, win* w, int a) {
    if (DEBUG) { lll("\t_focus"); }
    XWindowAttributes xw;
    Pixmap bt;
    unsigned int bt_w;
    unsigned int bt_h;
    int xh;
    int yh;
    if (!(XGetWindowAttributes(dpy, w->window, &xw))) { return; }
    XSetWindowBorder(dpy, w->window, (a ? BORDER_ACTIVE_COLOR : BORDER_INACTIVE_COLOR));
    //XSetWindowBackground(dpy, w->t, (a ? TITLEBAR_ACTIVE_COLOR : TITLEBAR_INACTIVE_COLOR));
    XSetWindowBorder(dpy, w->t, (a ? TITLEBAR_BORDER_ACTIVE_COLOR : TITLEBAR_BORDER_INACTIVE_COLOR));
    XSetBackground(dpy, w->gc, (a ? TITLEBAR_ACTIVE_COLOR : TITLEBAR_INACTIVE_COLOR));
    XSetForeground(dpy, w->gc, (a ? TEXT_ACTIVE_COLOR : TEXT_INACTIVE_COLOR));
    if (XReadBitmapFile(dpy, w->t, TITLEBAR_DECORATION, &bt_w, &bt_h, &bt, &xh, &yh) == BitmapSuccess) {
        Pixmap px = XCreatePixmap(dpy, w->t, bt_w, bt_h, DefaultDepth(dpy, DefaultScreen(dpy)));
        XCopyPlane(dpy, bt, px, w->gc, 0, 0, bt_w, bt_h, 0, 0, 1);
        XSetWindowBackgroundPixmap(dpy, w->t, px);
    } else { XSetWindowBackground(dpy, w->t, (a ? TITLEBAR_ACTIVE_COLOR : TITLEBAR_INACTIVE_COLOR)); }
    _refresh_bar(dpy);
    _text(dpy, w);
}

void _destroy_decorations(Display* dpy, win* w) {
    if (DEBUG) { lll("\t_destroy_dec"); }
    XSelectInput(dpy, w->window, NoEventMask);
    XSelectInput(dpy, w->s, NoEventMask);
    XSelectInput(dpy, w->t, NoEventMask);
    XFreeGC(dpy, w->gc);
    XUnmapWindow(dpy, w->s);
    XDestroyWindow(dpy, w->s);
    XUnmapWindow(dpy, w->t);
    XDestroyWindow(dpy, w->t);
    w->s = 0;
    w->t = 0;
}

//void _button(Display* dpy, win* w, int x, int y, unsigned int width, unsigned int h, int i) {
//    if (DEBUG) { lll("\t_button"); }
//    Window temp = XCreateSimpleWindow(dpy, w->t, x, y, width, h, 1, 0x000000, 0xFFFFFF);
//    XMapWindow(dpy, temp);
//}

void _move(Display* dpy, win* w, int btn, int dx, int dy) {
    if (DEBUG) { lll("\t_move"); }
    XMoveResizeWindow(dpy, w->window,
                      w->x + (btn == 1 ? dx : 0),
                      w->y + (btn == 1 ? dy : 0),
                      MAX(1, w->w + (btn == 3 ? dx : 0)),
                      MAX(1, w->h + (btn == 3 ? dy : 0)));
    XMoveResizeWindow(dpy, w->s,
                      w->x + SHADOW_X + (btn == 1 ? dx : 0),
                      w->y + SHADOW_Y - TITLEBAR_HEIGHT + (btn == 1 ? dy : 0),
                      MAX(1, w->w + BORDER_WIDTH * 2 + (btn == 3 ? dx : 0)),
                      MAX(1, w->h + TITLEBAR_HEIGHT + BORDER_WIDTH * 2 + (btn == 3 ? dy : 0)));
    XMoveResizeWindow(dpy, w->t,
                      w->x + (btn == 1 ? dx : 0),
                      w->y - TITLEBAR_HEIGHT + (btn == 1 ? dy : 0),
                      MAX(1, w->w + (BORDER_WIDTH * 2 - TITLEBAR_BORDER_WIDTH * 2) + (btn == 3 ? dx : 0)),
                      TITLEBAR_HEIGHT);
    _text(dpy, w);
}

void _text(Display* dpy, win* w) {
    if (DEBUG) { lll("\t_text"); }
    int x, y, d, asc, desc;
    XCharStruct overall;
    XTextProperty name;
    XGCValues gcv;
    if (!(XGetWMName(dpy, w->window, &name))) { name.value = "?"; }
    XTextExtents(XLoadQueryFont(dpy, TEXT_FONT), (char *)name.value, strlen((char *)name.value), &d, &asc, &desc, &overall);
    y = ((TITLEBAR_HEIGHT + asc - desc - TITLEBAR_BORDER_WIDTH) / 2);
    x = 3;
    XClearWindow(dpy, w->t);
    XGetGCValues(dpy, w->gc, GCBackground | GCForeground, &gcv);
    XDrawRectangle(dpy, w->t, w->gc, x - 4, y - asc - 3, overall.width + 7, desc + asc + 6);
    XSetForeground(dpy, w->gc, gcv.background);
    XFillRectangle(dpy, w->t, w->gc, x - 3, y - asc - 3, overall.width + 6, desc + asc + 6);
    XSetForeground(dpy, w->gc, gcv.foreground);
    XDrawImageString(dpy, w->t, w->gc, x, y, (char *)name.value, strlen((char *)name.value));
}

int _status(Display* dpy) {
    if (DEBUG) { lll("_status"); }
    if (!BAR_HEIGHT) { return 0; }
    int x, y, d, asc, desc;
    XCharStruct overall;
    XTextProperty name;
    XGCValues gcv;
    if (!(XGetWMName(dpy, DefaultRootWindow(dpy), &name))) { name.value = "V S W M"; }
    XTextExtents(XLoadQueryFont(dpy, TEXT_FONT), (char *)name.value, strlen((char *)name.value), &d, &asc, &desc, &overall);
    y = (BAR_HEIGHT + asc - desc) / 2;
    x = 3;
    XClearWindow(dpy, bar);
    XSetBackground(dpy, bar_gc, BAR_BACKGROUND);
    XSetForeground(dpy, bar_gc, BAR_TEXT);
    XDrawRectangle(dpy, bar, bar_gc, x - 4, y - asc - 3, overall.width + 7, desc + asc + 6);
    XGetGCValues(dpy, bar_gc, GCBackground | GCForeground, &gcv);
    XSetForeground(dpy, bar_gc, gcv.background);
    XFillRectangle(dpy, bar, bar_gc, x - 3, y - asc - 3, overall.width + 6, desc + asc + 6);
    XSetForeground(dpy, bar_gc, gcv.foreground);
    XDrawImageString(dpy, bar, bar_gc, x, y, (char *)name.value, strlen((char *)name.value));
    return overall.width + 6;
}

void _create_bar(Display* dpy) {
    XWindowAttributes attr;
    XSetWindowAttributes xw;
    bar = XCreateWindow(dpy, DefaultRootWindow(dpy), 0, 0, WidthOfScreen(DefaultScreenOfDisplay(dpy)) - 2 * BAR_BORDER_WIDTH, BAR_HEIGHT, BAR_BORDER_WIDTH, CopyFromParent, InputOutput, CopyFromParent, 0, &xw);
    Pixmap bt;
    unsigned int bt_w;
    unsigned int bt_h;
    int xh;
    int yh;
    if (!(XGetWindowAttributes(dpy, bar, &attr))) { return; }
    else {
        bar_gc = XCreateGC(dpy, bar, 0, 0);
        bar_s = XCreateSimpleWindow(dpy, DefaultRootWindow(dpy), 0, BAR_HEIGHT + 2 * BAR_BORDER_WIDTH, WidthOfScreen(DefaultScreenOfDisplay(dpy)), BAR_SHADOW_Y, 0, 0, BAR_SHADOW);
    }
    XSetWindowBorder(dpy, bar, BAR_BORDER);
    XSetBackground(dpy, bar_gc, BAR_BACKGROUND);
    XSetForeground(dpy, bar_gc, BAR_TEXT);
    XSetFont(dpy, bar_gc, XLoadQueryFont(dpy, TEXT_FONT)->fid);
    if (XReadBitmapFile(dpy, bar, BAR_DECORATION, &bt_w, &bt_h, &bt, &xh, &yh) == BitmapSuccess) {
        Pixmap px = XCreatePixmap(dpy, bar, bt_w, bt_h, DefaultDepth(dpy, DefaultScreen(dpy)));
        XCopyPlane(dpy, bt, px, bar_gc, 0, 0, bt_w, bt_h, 0, 0, 1);
        XSetWindowBackgroundPixmap(dpy, bar, px);
    } else { XSetWindowBackground(dpy, bar, BAR_BACKGROUND); }
    XMapWindow(dpy, bar_s);
    XMapWindow(dpy, bar);
    _status(dpy);
}

void _refresh_bar(Display* dpy) {
    if (DEBUG) { lll("_refresh_bar"); }
    if (!BAR_HEIGHT) { return; }
    XClearWindow(dpy, bar);
    int all_x = _status(dpy) + 3 + 10;
    XSetBackground(dpy, bar_gc, TITLEBAR_INACTIVE_COLOR);
    XSetForeground(dpy, bar_gc, TEXT_INACTIVE_COLOR);
    for (ALL_WINDOWS) {
        int x, y, d, asc, desc;
        XCharStruct overall;
        XTextProperty name;
        XGCValues gcv;
        XWindowAttributes xw;
        //if (!(XGetWindowAttributes(dpy, w->window, &xw))) { continue; }
        if (!(XGetWMName(dpy, w->window, &name))) { name.value = "?"; }
        XTextExtents(XLoadQueryFont(dpy, TEXT_FONT), (char *)name.value, strlen((char *)name.value), &d, &asc, &desc, &overall);
        y = (BAR_HEIGHT + asc - desc) / 2;
        XSetForeground(dpy, bar_gc, TEXT_ACTIVE_COLOR);
        XDrawRectangle(dpy, bar, bar_gc, all_x - 4, y - asc - 3, overall.width + 7, desc + asc + 6);
        XSetForeground(dpy, bar_gc, TEXT_INACTIVE_COLOR);
        if (w == active) {
            XSetBackground(dpy, bar_gc, TITLEBAR_ACTIVE_COLOR);
            XSetForeground(dpy, bar_gc, TEXT_ACTIVE_COLOR);
        }
        XGetGCValues(dpy, bar_gc, GCBackground | GCForeground, &gcv);
        XSetForeground(dpy, bar_gc, gcv.background);
        XFillRectangle(dpy, bar, bar_gc, all_x - 3, y - asc - 3, overall.width + 6, desc + asc + 6);
        XSetForeground(dpy, bar_gc, gcv.foreground);
        XDrawImageString(dpy, bar, bar_gc, all_x, y, (char *)name.value, strlen((char *)name.value));
        if (w == active) {
            XSetBackground(dpy, bar_gc, TITLEBAR_INACTIVE_COLOR);
            XSetForeground(dpy, bar_gc, TEXT_INACTIVE_COLOR);
        }
        all_x += overall.width + 6 + 10;
    }
}

/* Keyboard - Mouse Functions */
void close(Display* dpy, XEvent ev, int arg) {
    if (DEBUG) { lll(" [CLOSE]"); }
    XGrabServer(dpy);
    if (active) {
        _destroy_decorations(dpy, active);
        XKillClient(dpy, active->window);
        _win_del(dpy, active);
        switch_window(dpy, ev, 0);
        _refresh_bar(dpy);
    }
    XUngrabServer(dpy);
}

void maximize(Display* dpy, XEvent ev, int arg) {
    if (active) {
        XWindowAttributes attr;
        XGetWindowAttributes(dpy, active->window, &attr);
        if (attr.width == XDisplayWidth(dpy, DefaultScreen(dpy)) && attr.height == XDisplayHeight(dpy, DefaultScreen(dpy)) && attr.x == -BORDER_WIDTH && attr.y == -BORDER_WIDTH) { XMoveResizeWindow(dpy, active->window, active->x, active->y, active->w, active->h); }
        else {
            XMoveResizeWindow(dpy, active->window, -BORDER_WIDTH, -BORDER_WIDTH + BAR_HEIGHT + BAR_BORDER_WIDTH + BAR_SHADOW_Y, XDisplayWidth(dpy, DefaultScreen(dpy)), XDisplayHeight(dpy, DefaultScreen(dpy)) - BAR_HEIGHT - BAR_BORDER_WIDTH - BAR_SHADOW_Y);
            _status(dpy);
        }
    }
}

void switch_window(Display* dpy, XEvent ev, int arg) {
    if (DEBUG) { lll("switch_window"); }
    if (active) {
        active = active->prev;
        XRaiseWindow(dpy, active->window);
        XSetInputFocus(dpy, active->window, RevertToParent, CurrentTime);
        _restack(dpy, active);
    }
}

void move(Display* dpy, XEvent ev, int arg) {
    if (active) {
        XRaiseWindow(dpy, active->window);
        _restack(dpy, active);
        switch (arg) {
            case LEFT:
                _move(dpy, active, 1, -MOVE_DELTA, 0);
                win_size(active->window, &(active->x), &(active->y), &(active->w), &(active->h));
                break;
            case DOWN:
                _move(dpy, active, 1, 0, MOVE_DELTA);
                win_size(active->window, &(active->x), &(active->y), &(active->w), &(active->h));
                break;
            case UP:
                _move(dpy, active, 1, 0, -MOVE_DELTA);
                win_size(active->window, &(active->x), &(active->y), &(active->w), &(active->h));
                break;
            case RIGHT:
                _move(dpy, active, 1, MOVE_DELTA, 0);
                win_size(active->window, &(active->x), &(active->y), &(active->w), &(active->h));
                break;
            default:
                break;
        }
    }
}

void logout(Display* dpy, XEvent ev, int arg) {
    if (DEBUG) { lll("=== ΕΝD SESSION"); }
    running = 0;
}

void center(Display* dpy, XEvent ev, int arg) {
    if (active) { 
        _move(dpy, active, 1, (((WidthOfScreen(DefaultScreenOfDisplay(dpy)) - active->w) / 2) - active->x), (((HeightOfScreen(DefaultScreenOfDisplay(dpy)) - active->h) / 2) - active->y)); 
        win_size(active->window, &(active->x), &(active->y), &(active->w), &(active->h));    
    }
}

void event_handler(Display* dpy, XEvent ev) {
    win *w;
    XSetWindowAttributes attr;
    switch (ev.type) {
        case ConfigureRequest:
            if (DEBUG) { lll("configurereq"); }
            XConfigureWindow(dpy, ev.xconfigurerequest.window, ev.xconfigurerequest.value_mask, &(XWindowChanges){
                                                                                                    .x = ev.xconfigurerequest.x,
                                                                                                    .y = ev.xconfigurerequest.y,
                                                                                                    .width = ev.xconfigurerequest.width,
                                                                                                    .height = ev.xconfigurerequest.height,
                                                                                                });
            for (ALL_WINDOWS) {
                if (w->window == ev.xconfigurerequest.window) {
                    w->x = ev.xconfigurerequest.x;
                    w->y = ev.xconfigurerequest.y;
                    w->w = ev.xconfigurerequest.width;
                    w->h = ev.xconfigurerequest.height;
                    XMoveResizeWindow(dpy, w->s, w->x + SHADOW_X, w->y + SHADOW_Y - TITLEBAR_HEIGHT, w->w + BORDER_WIDTH * 2, w->h + BORDER_WIDTH * 2 + TITLEBAR_HEIGHT);
                    XMoveResizeWindow(dpy, w->t, w->x, w->y - TITLEBAR_HEIGHT, w->w + (BORDER_WIDTH * 2 - TITLEBAR_BORDER_WIDTH * 2), TITLEBAR_HEIGHT);
                    _restack(dpy, w);
                }
            }
            break;
        case MapRequest:
            if (DEBUG) { lll("mapreq"); }
            if (!(w = (win *)calloc(1, sizeof(win)))) { exit(1); }
            win_size(ev.xmaprequest.window, &(w->x), &(w->y), &(w->w), &(w->h));
            w->window = ev.xmaprequest.window;
            XSelectInput(dpy, w->window, StructureNotifyMask | EnterWindowMask | FocusChangeMask | PropertyChangeMask);
            w->s = XCreateSimpleWindow(dpy, DefaultRootWindow(dpy), w->x + SHADOW_X, w->y + SHADOW_Y, w->w + BORDER_WIDTH * 2, w->h + TITLEBAR_HEIGHT + BORDER_WIDTH * 2, 0, SHADOW_COLOR, SHADOW_COLOR);
            w->t = XCreateWindow(dpy, DefaultRootWindow(dpy), w->x, w->y, w->w + (BORDER_WIDTH * 2 - TITLEBAR_BORDER_WIDTH * 2), TITLEBAR_HEIGHT, TITLEBAR_BORDER_WIDTH, CopyFromParent, InputOutput, CopyFromParent, 0, &attr);
            w->gc = XCreateGC(dpy, w->t, 0, 0);
            XSetFont(dpy, w->gc, XLoadQueryFont(dpy, TEXT_FONT)->fid);
            XSelectInput(dpy, w->t, EnterWindowMask | ButtonPressMask | ButtonReleaseMask | PointerMotionMask | ExposureMask);
            XSelectInput(dpy, w->s, EnterWindowMask | ButtonPressMask | ButtonReleaseMask | PointerMotionMask);
            w->y += TITLEBAR_HEIGHT + (BAR_HEIGHT ? (BAR_HEIGHT + (2 * BAR_BORDER_WIDTH) + BAR_SHADOW_Y) : 0);
            active = w;
            _win_add(dpy, w);
            XSetWindowBorderWidth(dpy, w->window, BORDER_WIDTH);
            XMapWindow(dpy, w->s);
            XMapWindow(dpy, w->t);
            XMapWindow(dpy, w->window);
            _restack(dpy, w);
            _move(dpy, w, 0, 0, 0);
            XSetInputFocus(dpy, w->window, RevertToParent, CurrentTime);
            break;
        case KeyPress:
            key_handler(dpy, ev);
            break;
        case EnterNotify:
            if (DEBUG) { lll("enternot"); }
            for (ALL_WINDOWS) {
                if (w->window == ev.xcrossing.window || w->t == ev.xcrossing.window || w->s == ev.xcrossing.window) {
                    XSetInputFocus(dpy, w->window, RevertToParent, CurrentTime);
                    active = w;
                }
            }
            break;
        case DestroyNotify:
            if (DEBUG) { lll("destroynot"); }
            for (ALL_WINDOWS) {
                if (w->window == ev.xdestroywindow.window) {
                    active = w;
                    close(dpy, ev, 1);
                    break;
                }
            }
            _refresh_bar(dpy);
            break;
        case UnmapNotify:
            if (DEBUG) { lll("unmapnot"); }
            for (ALL_WINDOWS) {
                if (w->window == ev.xunmap.window) {
                    active = w;
                    close(dpy, ev, 2);
                    break;
                }
            }
            _refresh_bar(dpy);
            break;
        case FocusIn:
            if (DEBUG) { lll("focusin"); }
            for (ALL_WINDOWS) {
                if (w->window == ev.xfocus.window) { _focus(dpy, w, ACTIVE); }
            }
            break;
        case FocusOut:
            if (DEBUG) { lll("focusout"); }
            for (ALL_WINDOWS) {
                if (w->window == ev.xfocus.window) { _focus(dpy, w, INACTIVE); }
            }
            break;
        case Expose:
            if (DEBUG) { lll("expose"); }
            if (bar == ev.xexpose.window) {
                _refresh_bar(dpy);
                break;
            }
            for (ALL_WINDOWS) {
                if (w->t == ev.xexpose.window) {
                    if (w != active) { _text(dpy, w); }
                }
            }
            break;
        case ButtonPress:
            break;
        case ButtonRelease:
            break;
        case MotionNotify:
            break;
        case PropertyNotify:
            if (ev.xproperty.window == DefaultRootWindow(dpy)) {
                _refresh_bar(dpy);
                break;
            }
            for (ALL_WINDOWS) {
                if (w->window == ev.xproperty.window) {
                    if (DEBUG) { lll("propertynot"); }
                    if (ev.xproperty.atom == XA_WM_NAME) {
                        _text(dpy, w);
                        _refresh_bar(dpy);
                    }
                    break;
                }
            }
            break;
        default:
            break;
    }
}

int main(void) {
    if (!(dpy = XOpenDisplay(0x0))) { return 1; }
    XTextProperty wm_name;
    wm_name.value = "VSWM";
    wm_name.nitems = 1;

    XSetWMName(dpy, DefaultRootWindow(dpy), &wm_name);

    if (DEBUG) { lll("=== SESSION"); }
    XSetErrorHandler(error_handler);

    XSelectInput(dpy, DefaultRootWindow(dpy), SubstructureRedirectMask | PropertyChangeMask);
    XGrabButton(dpy, 1, MOVE_KEY, DefaultRootWindow(dpy), True, ButtonPressMask | ButtonReleaseMask | PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None);
    XGrabButton(dpy, 3, MOVE_KEY, DefaultRootWindow(dpy), True, ButtonPressMask | ButtonReleaseMask | PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None);
    key_init(dpy);

    XDefineCursor(dpy, DefaultRootWindow(dpy), XCreateFontCursor(dpy, 68));
    start.subwindow = None;

    _create_bar(dpy);
    while (running) {
        XNextEvent(dpy, &ev);

        event_handler(dpy, ev);
        if (ev.type == ButtonPress) {
            start = ev.xbutton;
            if (ev.xbutton.subwindow == None && !(ev.xbutton.state & MOVE_KEY)) {
                XRaiseWindow(dpy, active->window);
                _restack(dpy, active);
                _text(dpy, active);
                start.subwindow = ev.xbutton.window;
            }
        } else if (ev.type == MotionNotify && start.subwindow != None) {
            if (start.subwindow == bar || start.subwindow == bar_s) {
                start.subwindow = None;
                continue;
            }
            int xdiff = ev.xbutton.x_root - start.x_root;
            int ydiff = ev.xbutton.y_root - start.y_root;
            int btn = 0;
            for (ALL_WINDOWS) {
                if (w->s == ev.xbutton.window) {
                    if (start.button == 1) { btn = 3; }
                    if (start.button == 3) { btn = 1; }
                } else { btn = start.button; }
            }
            _move(dpy, active, btn, xdiff, ydiff);
        } else if (ev.type == ButtonRelease) {
            start.subwindow = None;
            if (active) { win_size(active->window, &(active->x), &(active->y), &(active->w), &(active->h)); }
        }
    }

    return 0;
}
