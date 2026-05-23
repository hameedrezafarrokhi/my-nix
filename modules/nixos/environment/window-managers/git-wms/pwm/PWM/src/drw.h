#ifndef DRW_H
#define DRW_H

#include <X11/Xlib.h>

typedef struct {
    Display *dpy;
    int screen;
    Window root;
    Drawable drawable;
    GC gc;
    unsigned int w, h;
    XFontStruct *font;
} Drw;

Drw *drw_create(Display *dpy, int screen, Window root, unsigned int w, unsigned int h);
void drw_resize(Drw *drw, unsigned int w, unsigned int h);
void drw_setfont(Drw *drw, const char *fontname);
void drw_free(Drw *drw);

void drw_setscheme(Drw *drw, unsigned long fg, unsigned long bg);
void drw_rect(Drw *drw, int x, int y, unsigned int w, unsigned int h, int filled);
void drw_text(Drw *drw, int x, int y, unsigned int w, unsigned int h, const char *text);
void drw_map(Drw *drw, Window win, int x, int y, unsigned int w, unsigned int h);
unsigned int drw_font_getwidth(Drw *drw, const char *text);

unsigned long drw_clr_create(Drw *drw, const char *clrname);

#endif
