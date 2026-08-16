#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>

#include "progress.h"
#include "config.h"

struct ProgressWindow {
    Display *dpy;
    Window win;
    XftDraw *draw;
    XftFont *font;
    Colormap cmap;
    XftColor fg, dim, bar_fill;
    unsigned long bar_bg_pixel;
    int width, height;
    long last_update_ms;
    char title[256];
};

static long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long)ts.tv_sec * 1000L + ts.tv_nsec / 1000000L;
}

ProgressWindow *progress_open(Display *dpy, int x, int y, const char *title) {
    ProgressWindow *pw = calloc(1, sizeof(ProgressWindow));
    if (!pw) return NULL;
    pw->dpy = dpy;
    int screen = DefaultScreen(dpy);
    pw->width = 400;
    pw->height = 96;

    XSetWindowAttributes attrs;
    attrs.override_redirect = True;
    attrs.background_pixel = 0;
    attrs.event_mask = ExposureMask;

    pw->win = XCreateWindow(dpy, RootWindow(dpy, screen), x, y, (unsigned)pw->width, (unsigned)pw->height,
                             MENU_BORDER_WIDTH, DefaultDepth(dpy, screen), InputOutput,
                             DefaultVisual(dpy, screen), CWOverrideRedirect | CWBackPixel | CWEventMask, &attrs);

    pw->cmap = DefaultColormap(dpy, screen);
    XColor bg, border, barbg;
    XParseColor(dpy, pw->cmap, MENU_COLOR_BG, &bg); XAllocColor(dpy, pw->cmap, &bg);
    XParseColor(dpy, pw->cmap, MENU_COLOR_BORDER, &border); XAllocColor(dpy, pw->cmap, &border);
    XParseColor(dpy, pw->cmap, MENU_COLOR_DISABLED_FG, &barbg); XAllocColor(dpy, pw->cmap, &barbg);
    pw->bar_bg_pixel = barbg.pixel;
    XSetWindowBackground(dpy, pw->win, bg.pixel);
    XSetWindowBorder(dpy, pw->win, border.pixel);

    pw->font = XftFontOpenName(dpy, screen, MENU_FONT);
    pw->draw = XftDrawCreate(dpy, pw->win, DefaultVisual(dpy, screen), pw->cmap);
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), pw->cmap, MENU_COLOR_FG, &pw->fg);
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), pw->cmap, MENU_COLOR_DISABLED_FG, &pw->dim);
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), pw->cmap, MENU_COLOR_SELECT_BG, &pw->bar_fill);

    snprintf(pw->title, sizeof(pw->title), "%s", title ? title : "");

    XMapRaised(dpy, pw->win);
    XSync(dpy, False);
    pw->last_update_ms = 0;
    progress_update(pw, "", 0.0);
    return pw;
}

void progress_update(ProgressWindow *pw, const char *current_file, double fraction) {
    if (!pw) return;

    long now = now_ms();
    int is_final = fraction >= 0.999;
    if (pw->last_update_ms != 0 && !is_final && (now - pw->last_update_ms) < 80) return; /* throttle */
    pw->last_update_ms = now;

    XEvent ev;
    while (XCheckWindowEvent(pw->dpy, pw->win, ExposureMask, &ev)) { }

    XClearWindow(pw->dpy, pw->win);

    XftDrawStringUtf8(pw->draw, &pw->fg, pw->font, MENU_ITEM_PAD_X, MENU_ITEM_PAD_Y + pw->font->ascent,
                       (const FcChar8 *)pw->title, (int)strlen(pw->title));

    char filebuf[300];
    snprintf(filebuf, sizeof(filebuf), "%s", current_file ? current_file : "");
    int line_h = pw->font->ascent + pw->font->descent;
    int file_y = MENU_ITEM_PAD_Y + line_h + pw->font->ascent;
    XftDrawStringUtf8(pw->draw, &pw->dim, pw->font, MENU_ITEM_PAD_X, file_y,
                       (const FcChar8 *)filebuf, (int)strlen(filebuf));

    int bar_x = MENU_ITEM_PAD_X;
    int bar_y = file_y + pw->font->descent + 10;
    int bar_w = pw->width - 2 * MENU_ITEM_PAD_X;
    int bar_h = 14;

    GC gc = XCreateGC(pw->dpy, pw->win, 0, NULL);
    XSetForeground(pw->dpy, gc, pw->bar_bg_pixel);
    XFillRectangle(pw->dpy, pw->win, gc, bar_x, bar_y, (unsigned)bar_w, (unsigned)bar_h);
    double f = fraction < 0 ? 0 : (fraction > 1 ? 1 : fraction);
    int fill_w = (int)((double)bar_w * f);
    if (fill_w > 0) {
        XSetForeground(pw->dpy, gc, pw->bar_fill.pixel);
        XFillRectangle(pw->dpy, pw->win, gc, bar_x, bar_y, (unsigned)fill_w, (unsigned)bar_h);
    }
    XFreeGC(pw->dpy, gc);

    char pct[16];
    snprintf(pct, sizeof(pct), "%d%%", (int)(f * 100));
    int pct_y = bar_y + bar_h + pw->font->ascent + 4;
    XftDrawStringUtf8(pw->draw, &pw->fg, pw->font, MENU_ITEM_PAD_X, pct_y, (const FcChar8 *)pct, (int)strlen(pct));

    XFlush(pw->dpy);
}

void progress_close(ProgressWindow *pw) {
    if (!pw) return;
    XftDrawDestroy(pw->draw);
    XftFontClose(pw->dpy, pw->font);
    XDestroyWindow(pw->dpy, pw->win);
    XFlush(pw->dpy);
    free(pw);
}
