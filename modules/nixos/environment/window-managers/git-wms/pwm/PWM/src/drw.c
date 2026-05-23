#include "drw.h"
#include "util.h"

#include <stdlib.h>
#include <string.h>

static unsigned long drw_fg;
static unsigned long drw_bg;

Drw *
drw_create(Display *dpy, int screen, Window root, unsigned int w, unsigned int h)
{
    Drw *drw = ecalloc(1, sizeof(*drw));
    drw->dpy = dpy;
    drw->screen = screen;
    drw->root = root;
    drw->w = w;
    drw->h = h;
    drw->drawable = XCreatePixmap(dpy, root, w, h, DefaultDepth(dpy, screen));
    drw->gc = XCreateGC(dpy, root, 0, NULL);
    return drw;
}

void
drw_resize(Drw *drw, unsigned int w, unsigned int h)
{
    if (drw->drawable)
        XFreePixmap(drw->dpy, drw->drawable);
    drw->w = w;
    drw->h = h;
    drw->drawable = XCreatePixmap(drw->dpy, drw->root, w, h, DefaultDepth(drw->dpy, drw->screen));
}

void
drw_setfont(Drw *drw, const char *fontname)
{
    if (drw->font)
        XFreeFont(drw->dpy, drw->font);
    drw->font = XLoadQueryFont(drw->dpy, fontname);
    if (drw->font)
        XSetFont(drw->dpy, drw->gc, drw->font->fid);
}

void
drw_free(Drw *drw)
{
    if (!drw)
        return;
    if (drw->font)
        XFreeFont(drw->dpy, drw->font);
    XFreePixmap(drw->dpy, drw->drawable);
    XFreeGC(drw->dpy, drw->gc);
    free(drw);
}

void
drw_setscheme(Drw *drw, unsigned long fg, unsigned long bg)
{
    drw_fg = fg;
    drw_bg = bg;
    XSetForeground(drw->dpy, drw->gc, drw_bg);
}

void
drw_rect(Drw *drw, int x, int y, unsigned int w, unsigned int h, int filled)
{
    XSetForeground(drw->dpy, drw->gc, drw_bg);
    if (filled)
        XFillRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w, h);
    else
        XDrawRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w, h);
}

void
drw_text(Drw *drw, int x, int y, unsigned int w, unsigned int h, const char *text)
{
    int tx = x + 6;
    int ty = y + (int)((h + drw->font->ascent - drw->font->descent) / 2);

    XSetForeground(drw->dpy, drw->gc, drw_bg);
    XFillRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w, h);
    XSetForeground(drw->dpy, drw->gc, drw_fg);
    if (text && *text)
        XDrawString(drw->dpy, drw->drawable, drw->gc, tx, ty, text, (int)strlen(text));
}

unsigned int
drw_font_getwidth(Drw *drw, const char *text)
{
    if (!drw || !drw->font || !text)
        return 0;
    return (unsigned int)XTextWidth(drw->font, text, (int)strlen(text));
}

void
drw_map(Drw *drw, Window win, int x, int y, unsigned int w, unsigned int h)
{
    XCopyArea(drw->dpy, drw->drawable, win, drw->gc, x, y, w, h, x, y);
    XSync(drw->dpy, False);
}

unsigned long
drw_clr_create(Drw *drw, const char *clrname)
{
    XColor color, dummy;
    Colormap cmap = DefaultColormap(drw->dpy, drw->screen);
    if (!XAllocNamedColor(drw->dpy, cmap, clrname, &color, &dummy))
        return BlackPixel(drw->dpy, drw->screen);
    return color.pixel;
}
