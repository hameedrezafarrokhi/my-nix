/*
 * xinput.c
 *
 * Minimal modal single-line text box. Deliberately not a general
 * text-editing widget -- no cursor movement beyond end-of-line, no
 * selection, no clipboard paste. It exists for one purpose (typing a
 * short filesystem-safe leaf name for a mount-point symlink) and is
 * kept as small as that purpose allows. Visual style matches
 * xmenu/fmenu so it doesn't look like a bolted-on afterthought.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/Xft/Xft.h>

#include "xinput.h"
#include "config.h"

#define BUF_CAP 512

char *xinput_show(Display *dpy, int x, int y, const char *prompt, const char *initial) {
    int screen = DefaultScreen(dpy);
    Window root = RootWindow(dpy, screen);

    int width = MENU_MAX_WIDTH > 0 ? MENU_MAX_WIDTH : 380;
    int height = 76;

    XSetWindowAttributes attrs;
    attrs.override_redirect = True;
    attrs.background_pixel = 0;
    attrs.event_mask = KeyPressMask | ExposureMask | FocusChangeMask;

    Window win = XCreateWindow(dpy, root, x, y, width, height, MENU_BORDER_WIDTH,
                                DefaultDepth(dpy, screen), InputOutput, DefaultVisual(dpy, screen),
                                CWOverrideRedirect | CWBackPixel | CWEventMask, &attrs);

    XColor bg, border;
    Colormap cmap = DefaultColormap(dpy, screen);
    XParseColor(dpy, cmap, MENU_COLOR_BG, &bg);
    XAllocColor(dpy, cmap, &bg);
    XParseColor(dpy, cmap, MENU_COLOR_BORDER, &border);
    XAllocColor(dpy, cmap, &border);
    XSetWindowBackground(dpy, win, bg.pixel);
    XSetWindowBorder(dpy, win, border.pixel);

    XftFont *font = XftFontOpenName(dpy, screen, MENU_FONT);
    XftDraw *draw = XftDrawCreate(dpy, win, DefaultVisual(dpy, screen), cmap);
    XftColor fg, dim;
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), cmap, MENU_COLOR_FG, &fg);
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), cmap, MENU_COLOR_DISABLED_FG, &dim);

    char buf[BUF_CAP];
    snprintf(buf, sizeof(buf), "%s", initial ? initial : "");
    int len = (int)strlen(buf);

    XMapRaised(dpy, win);
    XSetInputFocus(dpy, win, RevertToParent, CurrentTime);
    /* Best-effort keyboard grab -- if it fails (some WMs are picky
     * about grabs on override-redirect windows), we still work as
     * long as the window has input focus, just without guaranteed
     * exclusivity. */
    XGrabKeyboard(dpy, win, True, GrabModeAsync, GrabModeAsync, CurrentTime);

    int confirmed = 0, cancelled = 0;

    while (!confirmed && !cancelled) {
        XEvent ev;
        XNextEvent(dpy, &ev);

        if (ev.type == Expose || ev.type == FocusIn) {
            XClearWindow(dpy, win);
            XftDrawStringUtf8(draw, &dim, font, MENU_ITEM_PAD_X, MENU_ITEM_PAD_Y + font->ascent,
                               (const FcChar8 *)prompt, (int)strlen(prompt));
            int input_y = MENU_ITEM_PAD_Y * 2 + font->ascent + font->descent + font->ascent;
            char shown[BUF_CAP + 2];
            snprintf(shown, sizeof(shown), "%s\xE2\x96\x8F", buf); /* trailing thin cursor block */
            XftDrawStringUtf8(draw, &fg, font, MENU_ITEM_PAD_X, input_y,
                               (const FcChar8 *)shown, (int)strlen(shown));
            continue;
        }

        if (ev.type != KeyPress) continue;

        char keybuf[32];
        KeySym ksym;
        XLookupString(&ev.xkey, keybuf, sizeof(keybuf), &ksym, NULL);

        if (ksym == XK_Return || ksym == XK_KP_Enter) {
            confirmed = 1;
        } else if (ksym == XK_Escape) {
            cancelled = 1;
        } else if (ksym == XK_BackSpace) {
            if (len > 0) { len--; buf[len] = '\0'; }
            XEvent fake; fake.type = Expose; XSendEvent(dpy, win, False, ExposureMask, &fake);
        } else {
            int n = (int)strlen(keybuf);
            if (n > 0 && len + n < BUF_CAP - 1) {
                memcpy(buf + len, keybuf, n);
                len += n;
                buf[len] = '\0';
            }
            XEvent fake; fake.type = Expose; XSendEvent(dpy, win, False, ExposureMask, &fake);
        }
    }

    XUngrabKeyboard(dpy, CurrentTime);
    XftDrawDestroy(draw);
    XftFontClose(dpy, font);
    XDestroyWindow(dpy, win);
    XFlush(dpy);

    if (cancelled) return NULL;
    return strdup(buf);
}
