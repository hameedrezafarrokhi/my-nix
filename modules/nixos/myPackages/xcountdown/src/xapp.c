#define _POSIX_C_SOURCE 200809L
#include "xapp.h"
#include "timefmt.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/extensions/Xrender.h>
#include <X11/extensions/shape.h>
#include <X11/Xft/Xft.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>
#include <sys/select.h>
#include <sys/wait.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define DOUBLE_CLICK_MS 350
#define HOLD_THRESHOLD_MS 180
#define MAX_IDLE_WAKE_MS 1000  /* re-check at least this often even when "idle" */
#define ALARM_REPLAY_INTERVAL_MS 2500

/* ---------------- app state ---------------- */

typedef struct {
    Display *dpy;
    int screen;
    Window win;
    Window root;
    Visual *visual;
    int depth;
    Colormap cmap;
    int has_argb;
    int has_compositor;
    int true_transparency;   /* has_argb && has_compositor */
    bg_style_t effective_bg; /* cfg->bg, with none/transparent downgraded to
                               * square when true_transparency isn't available */

    Pixmap backbuf;
    Picture backbuf_pic;
    Picture win_pic;
    XftDraw *xftdraw;
    XftFont *font;
    XftFont *label_font;

    int width, height;
    int x, y;

    config_t *cfg;

    long remaining_seconds;
    long total_seconds;
    struct timespec last_tick;
    int paused;
    int finished;

    struct timespec app_start;
    struct timespec last_frame_ts;
    double anim_clock; /* only advances while animation is "allowed" (see
                         * cfg->animate_when_active / animate_when_paused) */

    /* click / drag state machine */
    int b1_down, b1_dragging;
    struct timespec b1_press_time;
    int drag_off_x, drag_off_y;

    int left_pending, right_pending;
    struct timespec left_deadline, right_deadline;
    struct timespec last_left_release, last_right_release;
    int have_last_left_release, have_last_right_release;

    /* per-segment countdown display (e.g. h / m / s rendered and animated
     * independently, so with --animate-changed-segment-only only the
     * fastest-changing field pulses, and transitions only ever move
     * whichever segment(s) actually changed) */
    int nsegs;
    char seg_cur[TIMEFMT_MAX_SEGMENTS][TIMEFMT_SEG_SIZE];
    char seg_prev[TIMEFMT_MAX_SEGMENTS][TIMEFMT_SEG_SIZE];
    int seg_transitioning[TIMEFMT_MAX_SEGMENTS];
    double seg_transition_start[TIMEFMT_MAX_SEGMENTS];
    int seg_slot_width[TIMEFMT_MAX_SEGMENTS]; /* stable per-segment layout width */
    int sep_width;                             /* width of the ":" separator glyph */

    /* surprise mode (always runs on its own real-time clock, independent
     * of pause/animation gating -- it's a brief, explicitly-triggered gag) */
    int surprise_active;
    struct timespec surprise_end;
    const char *surprise_text;

    /* finish alarm */
    int alarm_active;
    int alarm_play_count;
    struct timespec alarm_next_play;

    int force_redraw;
    int has_focus;
    Window prev_focus_win;
    int prev_focus_revert;
} app_t;

static volatile sig_atomic_t g_should_quit = 0;
static void on_sigterm(int sig) { (void)sig; g_should_quit = 1; }

/* ---------------- small time helpers ---------------- */

static double ts_diff(struct timespec a, struct timespec b) {
    /* a - b, in seconds */
    return (a.tv_sec - b.tv_sec) + (a.tv_nsec - b.tv_nsec) / 1e9;
}
static struct timespec ts_now(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t;
}
static struct timespec ts_add_ms(struct timespec t, double ms) {
    double sec = ms / 1000.0;
    t.tv_sec += (time_t)sec;
    t.tv_nsec += (long)((sec - (time_t)sec) * 1e9);
    if (t.tv_nsec >= 1000000000L) { t.tv_nsec -= 1000000000L; t.tv_sec += 1; }
    if (t.tv_nsec < 0) { t.tv_nsec += 1000000000L; t.tv_sec -= 1; }
    return t;
}

/* ---------------- color helpers ---------------- */

/* Parses "#rrggbb" or "#rrggbbaa" into 0-255 components. Returns 1 on success. */
static int parse_hex_color(const char *hex, int *r, int *g, int *b, int *a) {
    if (!hex || hex[0] != '#') return 0;
    size_t len = strlen(hex);
    unsigned int rr, gg, bb, aa = 255;
    if (len == 7) {
        if (sscanf(hex + 1, "%2x%2x%2x", &rr, &gg, &bb) != 3) return 0;
    } else if (len == 9) {
        if (sscanf(hex + 1, "%2x%2x%2x%2x", &rr, &gg, &bb, &aa) != 4) return 0;
    } else {
        return 0;
    }
    *r = (int)rr; *g = (int)gg; *b = (int)bb; *a = (int)aa;
    return 1;
}

/* Builds a premultiplied XRenderColor from straight 0-255 components and a
 * 0.0-1.0 extra alpha multiplier (used for flash/transition fades). */
static XRenderColor make_render_color(int r, int g, int b, int a, double extra_alpha) {
    double af = (a / 255.0) * extra_alpha;
    if (af < 0) af = 0;
    if (af > 1) af = 1;
    XRenderColor c;
    c.alpha = (unsigned short)(af * 65535.0);
    c.red   = (unsigned short)(af * (r / 255.0) * 65535.0);
    c.green = (unsigned short)(af * (g / 255.0) * 65535.0);
    c.blue  = (unsigned short)(af * (b / 255.0) * 65535.0);
    return c;
}

/* ---------------- X error handling ----------------
 * Focus changes on override-redirect windows can legitimately race with
 * the window disappearing/being unmapped; don't let benign errors crash
 * the whole widget. */
static int x_error_handler(Display *d, XErrorEvent *e) {
    char buf[256];
    XGetErrorText(d, e->error_code, buf, sizeof(buf));
    fprintf(stderr, "countdown: X error ignored: %s (request %d)\n", buf, e->request_code);
    return 0;
}

/* ---------------- layout / geometry ---------------- */

static void compute_window_size(app_t *app) {
    config_t *cfg = app->cfg;

    /* Render the widest plausible digit string for each segment so neither
     * the window nor any individual segment's slot jitters in width as
     * digits change. */
    char widest_segs[TIMEFMT_MAX_SEGMENTS][TIMEFMT_SEG_SIZE];
    app->nsegs = timefmt_render_segments(cfg->format, app->total_seconds, widest_segs, TIMEFMT_MAX_SEGMENTS);
    if (app->nsegs < 1) app->nsegs = 1;

    XGlyphInfo extents;
    int text_w = 0;
    for (int i = 0; i < app->nsegs; i++) {
        for (char *c = widest_segs[i]; *c; c++) if (*c >= '0' && *c <= '9') *c = '8';
        XftTextExtentsUtf8(app->dpy, app->font, (const FcChar8 *)widest_segs[i],
                            (int)strlen(widest_segs[i]), &extents);
        app->seg_slot_width[i] = extents.xOff;
        text_w += app->seg_slot_width[i];
    }
    XftTextExtentsUtf8(app->dpy, app->font, (const FcChar8 *)":", 1, &extents);
    app->sep_width = extents.xOff;
    text_w += app->sep_width * (app->nsegs - 1);

    int text_h = app->font->ascent + app->font->descent;

    int label_w = 0, label_h = 0;
    if (cfg->label[0]) {
        XGlyphInfo lext;
        XftTextExtentsUtf8(app->dpy, app->label_font, (const FcChar8 *)cfg->label, (int)strlen(cfg->label), &lext);
        label_w = lext.width;
        label_h = app->label_font->ascent + app->label_font->descent;
    }

    int content_w = text_w > label_w ? text_w : label_w;
    int content_h = text_h + (label_h > 0 ? label_h + 6 : 0);

    int pad = cfg->font_size / 2;
    if (pad < 12) pad = 12;

    int w, h;
    if (cfg->bg_size > 0) {
        w = h = cfg->bg_size;
    } else if (cfg->bg == BG_CIRCLE) {
        int diameter = content_w > content_h ? content_w : content_h;
        diameter += pad * 2;
        w = h = diameter;
    } else {
        w = content_w + pad * 2;
        h = content_h + pad * 2;
    }
    if (w < 8) w = 8;
    if (h < 8) h = 8;

    app->width = w;
    app->height = h;
}

static void compute_window_pos(app_t *app) {
    int sw = DisplayWidth(app->dpy, app->screen);
    int sh = DisplayHeight(app->dpy, app->screen);
    config_t *cfg = app->cfg;

    if (cfg->has_x) app->x = cfg->x >= 0 ? cfg->x : sw + cfg->x - app->width;
    else app->x = (sw - app->width) / 2;

    if (cfg->has_y) app->y = cfg->y >= 0 ? cfg->y : sh + cfg->y - app->height;
    else app->y = (sh - app->height) / 2;
}

/* ---------------- rounded-rect geometry (shared by fill + shape mask) ---------------- */

static int outer_bg_radius(int w, int h) {
    int m = w < h ? w : h;
    int r = m / 8;
    if (r < 6) r = 6;
    if (r > m / 2) r = m / 2;
    return r;
}

/* For a w x h rounded rect with corner radius `radius`, returns via *inset
 * how far each side of `row` is indented from the rect's left/right edges.
 * Used identically by the fill drawer and the shape-mask builder so the
 * window's real silhouette always matches what's actually painted. */
static void rounded_rect_row_inset(int w, int h, int radius, int row, int *inset) {
    (void)w;
    *inset = 0;
    if (radius <= 0) return;
    if (row < radius) {
        int dy = radius - row;
        double dx = sqrt((double)(radius * radius - dy * dy));
        *inset = radius - (int)dx;
    } else if (row >= h - radius) {
        int dy = row - (h - radius) + 1;
        double dx = sqrt((double)(radius * radius - dy * dy));
        *inset = radius - (int)dx;
    }
    if (*inset < 0) *inset = 0;
}

/* ---------------- background shape (X window shape, always applied) ----------------
 * We always shape the window to match whatever's actually painted (circle,
 * or a rounded rect for square/shadow/the no-compositor fallback). This
 * does two things regardless of whether a compositor is running:
 *  - keeps clicks on the transparent corners falling through (ShapeInput)
 *  - keeps the *visible* pixels confined to the real silhouette
 *    (ShapeBounding), so without a compositor you get a black circle/box
 *    instead of a black rectangle, and with one (e.g. picom), per-window
 *    blur/shadow effects stay contained to that silhouette too. */

static void apply_bg_shape(app_t *app) {
    if (app->effective_bg != BG_CIRCLE && app->effective_bg != BG_SQUARE &&
        app->effective_bg != BG_SHADOW) {
        return; /* BG_NONE/BG_TRANSPARENT with true transparency: full rect, no shaping needed */
    }

    Pixmap mask = XCreatePixmap(app->dpy, app->win, app->width, app->height, 1);
    XGCValues gcv;
    GC gc = XCreateGC(app->dpy, mask, 0, &gcv);
    XSetForeground(app->dpy, gc, 0);
    XFillRectangle(app->dpy, mask, gc, 0, 0, app->width, app->height);
    XSetForeground(app->dpy, gc, 1);

    if (app->effective_bg == BG_CIRCLE) {
        XFillArc(app->dpy, mask, gc, 0, 0, app->width, app->height, 0, 360 * 64);
    } else {
        int radius = outer_bg_radius(app->width, app->height);
        for (int row = 0; row < app->height; row++) {
            int inset;
            rounded_rect_row_inset(app->width, app->height, radius, row, &inset);
            int rw = app->width - 2 * inset;
            if (rw <= 0) continue;
            XFillRectangle(app->dpy, mask, gc, inset, row, rw, 1);
        }
    }

    XShapeCombineMask(app->dpy, app->win, ShapeInput, 0, 0, mask, ShapeSet);
    XShapeCombineMask(app->dpy, app->win, ShapeBounding, 0, 0, mask, ShapeSet);

    XFreeGC(app->dpy, gc);
    XFreePixmap(app->dpy, mask);
}

/* ---------------- compositor detection ---------------- */

static int detect_compositor(Display *dpy, int screen) {
    char propname[32];
    snprintf(propname, sizeof(propname), "_NET_WM_CM_S%d", screen);
    Atom cm_atom = XInternAtom(dpy, propname, False);
    return XGetSelectionOwner(dpy, cm_atom) != None;
}

/* ---------------- EWMH hints ---------------- */

static void set_ewmh_hints(app_t *app) {
    Atom net_wm_state = XInternAtom(app->dpy, "_NET_WM_STATE", False);
    Atom skip_taskbar = XInternAtom(app->dpy, "_NET_WM_STATE_SKIP_TASKBAR", False);
    Atom skip_pager   = XInternAtom(app->dpy, "_NET_WM_STATE_SKIP_PAGER", False);
    Atom sticky       = XInternAtom(app->dpy, "_NET_WM_STATE_STICKY", False);
    Atom above        = XInternAtom(app->dpy, "_NET_WM_STATE_ABOVE", False);

    Atom states[4];
    int n = 0;
    states[n++] = skip_taskbar;
    states[n++] = skip_pager;
    states[n++] = above;
    if (app->cfg->sticky) states[n++] = sticky;
    XChangeProperty(app->dpy, app->win, net_wm_state, XA_ATOM, 32,
                     PropModeReplace, (unsigned char *)states, n);

    if (app->cfg->sticky) {
        Atom net_wm_desktop = XInternAtom(app->dpy, "_NET_WM_DESKTOP", False);
        long all_desktops = 0xFFFFFFFF;
        XChangeProperty(app->dpy, app->win, net_wm_desktop, XA_CARDINAL, 32,
                         PropModeReplace, (unsigned char *)&all_desktops, 1);
    }

    Atom net_wm_type = XInternAtom(app->dpy, "_NET_WM_WINDOW_TYPE", False);
    Atom type_utility = XInternAtom(app->dpy, "_NET_WM_WINDOW_TYPE_UTILITY", False);
    XChangeProperty(app->dpy, app->win, net_wm_type, XA_ATOM, 32,
                     PropModeReplace, (unsigned char *)&type_utility, 1);

    XClassHint ch = { .res_name = (char *)"countdown", .res_class = (char *)"Countdown" };
    XSetClassHint(app->dpy, app->win, &ch);

    XWMHints wh;
    memset(&wh, 0, sizeof(wh));
    wh.flags = InputHint;
    wh.input = False; /* we manage focus ourselves on enter/leave */
    XSetWMHints(app->dpy, app->win, &wh);
}

/* ---------------- init / teardown ---------------- */

static int init_x(app_t *app) {
    app->dpy = XOpenDisplay(NULL);
    if (!app->dpy) {
        fprintf(stderr, "countdown: cannot open X display\n");
        return 0;
    }
    XSetErrorHandler(x_error_handler);
    app->screen = DefaultScreen(app->dpy);
    app->root = RootWindow(app->dpy, app->screen);

    XVisualInfo vinfo;
    app->has_argb = 0;
    if (XMatchVisualInfo(app->dpy, app->screen, 32, TrueColor, &vinfo)) {
        app->visual = vinfo.visual;
        app->depth = vinfo.depth;
        app->has_argb = 1;
    } else {
        app->visual = DefaultVisual(app->dpy, app->screen);
        app->depth = DefaultDepth(app->dpy, app->screen);
        fprintf(stderr, "countdown: no 32-bit ARGB visual available; "
                        "falling back to opaque rendering (no true transparency, "
                        "no compositor blending). Circle/shadow/flash still work.\n");
    }

    app->has_compositor = detect_compositor(app->dpy, app->screen);
    app->true_transparency = app->has_argb && app->has_compositor;

    app->effective_bg = app->cfg->bg;
    if (!app->true_transparency && (app->effective_bg == BG_NONE || app->effective_bg == BG_TRANSPARENT)) {
        fprintf(stderr, "countdown: no compositor detected, so real see-through "
                        "backgrounds aren't possible; using an opaque box instead "
                        "of what would otherwise be a solid black rectangle. "
                        "Run picom (or similar) for true transparency.\n");
        app->effective_bg = BG_SQUARE;
    }

    /* Real, font-aware window sizing happens later in xapp_run(), after
     * load_fonts() — app->font is still NULL here, so don't touch it. */
    return 1;
}

static int load_fonts(app_t *app) {
    char spec[192];
    snprintf(spec, sizeof(spec), "%s:size=%d", app->cfg->font, app->cfg->font_size);
    app->font = XftFontOpenName(app->dpy, app->screen, spec);
    if (!app->font) {
        fprintf(stderr, "countdown: could not load font '%s', falling back to 'Sans'\n", spec);
        app->font = XftFontOpenName(app->dpy, app->screen, "Sans:size=48");
    }
    if (!app->font) {
        fprintf(stderr, "countdown: could not load any font\n");
        return 0;
    }

    if (app->cfg->label[0]) {
        int lsize = app->cfg->font_size / 2;
        if (lsize < 8) lsize = 8;
        char lspec[192];
        snprintf(lspec, sizeof(lspec), "%s:size=%d", app->cfg->font, lsize);
        app->label_font = XftFontOpenName(app->dpy, app->screen, lspec);
        if (!app->label_font) app->label_font = app->font;
    }
    return 1;
}

static int create_window(app_t *app) {
    app->cmap = XCreateColormap(app->dpy, app->root, app->visual, AllocNone);

    XSetWindowAttributes attrs;
    memset(&attrs, 0, sizeof(attrs));
    attrs.colormap = app->cmap;
    attrs.border_pixel = 0;
    attrs.background_pixel = 0;
    attrs.override_redirect = True;
    attrs.event_mask = ExposureMask | ButtonPressMask | ButtonReleaseMask |
                        PointerMotionMask | EnterWindowMask | LeaveWindowMask |
                        StructureNotifyMask | KeyPressMask;

    unsigned long valuemask = CWColormap | CWBorderPixel | CWBackPixel |
                               CWOverrideRedirect | CWEventMask;

    app->win = XCreateWindow(app->dpy, app->root, app->x, app->y,
                              app->width, app->height, 0, app->depth,
                              InputOutput, app->visual, valuemask, &attrs);

    set_ewmh_hints(app);
    apply_bg_shape(app);

    XRenderPictFormat *fmt = XRenderFindVisualFormat(app->dpy, app->visual);
    app->win_pic = XRenderCreatePicture(app->dpy, app->win, fmt, 0, NULL);

    app->backbuf = XCreatePixmap(app->dpy, app->win, app->width, app->height, app->depth);
    app->backbuf_pic = XRenderCreatePicture(app->dpy, app->backbuf, fmt, 0, NULL);
    app->xftdraw = XftDrawCreate(app->dpy, app->backbuf, app->visual, app->cmap);

    XMapWindow(app->dpy, app->win);
    return 1;
}

static void teardown(app_t *app) {
    if (!app->dpy) return;
    if (app->xftdraw) XftDrawDestroy(app->xftdraw);
    if (app->font) XftFontClose(app->dpy, app->font);
    if (app->label_font && app->label_font != app->font) XftFontClose(app->dpy, app->label_font);
    if (app->backbuf_pic) XRenderFreePicture(app->dpy, app->backbuf_pic);
    if (app->win_pic) XRenderFreePicture(app->dpy, app->win_pic);
    if (app->backbuf) XFreePixmap(app->dpy, app->backbuf);
    if (app->win) XDestroyWindow(app->dpy, app->win);
    if (app->cmap) XFreeColormap(app->dpy, app->cmap);
    XCloseDisplay(app->dpy);
}

/* ---------------- flash / animation math ---------------- */

static double flash_alpha_factor(app_t *app) {
    if (!app->cfg->flash) return 1.0;
    double speed = app->cfg->flash_speed;
    if (speed < 1) speed = 1;
    if (speed > 10) speed = 10;
    double period = 2.0 * (5.0 / speed); /* seconds per full pulse cycle */
    /* anim_clock only advances while animation is "allowed" per
     * animate_when_active/animate_when_paused, so pausing naturally
     * freezes the phase right where it was -- no extra bookkeeping needed. */
    double phase = fmod(app->anim_clock / period, 1.0);
    if (phase < 0) phase += 1.0;

    double v, floor_alpha;
    switch (app->cfg->flash_style) {
        case FLASH_THROB: {
            /* two quick beats then a rest, like a heartbeat monitor */
            double b1 = exp(-pow((phase - 0.12) / 0.05, 2));
            double b2 = exp(-pow((phase - 0.28) / 0.06, 2));
            v = b1 > b2 ? b1 : b2;
            floor_alpha = 0.15;
            break;
        }
        case FLASH_BLINK:
            v = phase < 0.5 ? 1.0 : 0.0;
            floor_alpha = 0.0; /* true on/off, unlike the other styles */
            break;
        case FLASH_FADE:
        default:
            v = 0.5 - 0.5 * cos(phase * 2.0 * M_PI); /* smooth 0..1..0 */
            floor_alpha = 0.12; /* never fully invisible */
            break;
    }
    return floor_alpha + (1.0 - floor_alpha) * v;
}

static int animation_active(app_t *app) {
    if (app->surprise_active) return 1; /* independent of pause-gating, always finishes */
    int anim_allowed = app->paused ? app->cfg->animate_when_paused : app->cfg->animate_when_active;
    if (!anim_allowed) return 0;
    if (app->cfg->flash) return 1;
    for (int i = 0; i < app->nsegs; i++) if (app->seg_transitioning[i]) return 1;
    return 0;
}

/* ---------------- background drawing ---------------- */

static void draw_rounded_rect(app_t *app, int x, int y, int w, int h, int radius,
                               int r, int g, int b, int a, double extra_alpha) {
    XRenderColor col = make_render_color(r, g, b, a, extra_alpha);
    if (w <= 0 || h <= 0) return;
    if (radius <= 0) {
        XRenderFillRectangle(app->dpy, PictOpOver, app->backbuf_pic, &col, x, y, w, h);
        return;
    }
    if (radius > w / 2) radius = w / 2;
    if (radius > h / 2) radius = h / 2;
    /* Scanline fill: every row gets its own (correctly symmetric) inset, so
     * all four corners round off identically -- no missing/lopsided corners. */
    for (int row = 0; row < h; row++) {
        int inset;
        rounded_rect_row_inset(w, h, radius, row, &inset);
        int rw = w - 2 * inset;
        if (rw <= 0) continue;
        XRenderFillRectangle(app->dpy, PictOpOver, app->backbuf_pic, &col, x + inset, y + row, rw, 1);
    }
}

static void reset_clip(app_t *app); /* fwd decl: defined near draw_centered_text below */

static void draw_background(app_t *app) {
    int r, g, b, a;
    if (!parse_hex_color(app->cfg->bg_color, &r, &g, &b, &a)) { r = g = b = 0; a = 170; }
    /* Without a compositor, alpha is never blended against the real desktop,
     * so a translucent fill just looks like a flat (usually near-black,
     * since that's the clear color) box. Force full opacity in that case so
     * the fallback at least looks like an intentional solid widget. */
    if (!app->true_transparency) a = 255;

    reset_clip(app); /* undo any clip band left by a previous flip-style frame */

    /* Clear the backbuffer first. Only meaningful as "invisible" when a
     * compositor will actually blend it against the desktop -- otherwise
     * clear to the same opaque color we're about to fill with, so any
     * unpainted sliver (e.g. rounded-corner rounding error) doesn't flash
     * as a stray black pixel. */
    if (app->true_transparency) {
        XRenderColor clear = {0, 0, 0, 0};
        XRenderFillRectangle(app->dpy, PictOpSrc, app->backbuf_pic, &clear, 0, 0, app->width, app->height);
    } else {
        XRenderColor opaque = make_render_color(r, g, b, 255, 1.0);
        XRenderFillRectangle(app->dpy, PictOpSrc, app->backbuf_pic, &opaque, 0, 0, app->width, app->height);
    }

    switch (app->effective_bg) {
        case BG_NONE:
        case BG_TRANSPARENT:
            break; /* only reachable when true_transparency is available */
        case BG_SQUARE:
            draw_rounded_rect(app, 0, 0, app->width, app->height,
                               outer_bg_radius(app->width, app->height), r, g, b, a, 1.0);
            break;
        case BG_CIRCLE: {
            XRenderColor col = make_render_color(r, g, b, a, 1.0);
            /* Approximate the disc with horizontal strips (cheap, no extra
             * mask picture needed); good enough at widget sizes. The window
             * shape mask (apply_bg_shape) uses the exact same math, so the
             * visible fill and the real window silhouette always agree. */
            int cx = app->width / 2, cy = app->height / 2;
            int rx = app->width / 2, ry = app->height / 2;
            for (int row = 0; row < app->height; row++) {
                double dy = (row - cy) / (double)ry;
                if (dy < -1 || dy > 1) continue;
                double dx = sqrt(1.0 - dy * dy) * rx;
                int x0 = (int)(cx - dx);
                int w = (int)(2 * dx);
                if (w <= 0) continue;
                XRenderFillRectangle(app->dpy, PictOpOver, app->backbuf_pic, &col, x0, row, w, 1);
            }
            break;
        }
        case BG_SHADOW: {
            /* Cheap soft shadow: a handful of shrinking, increasingly
             * opaque rounded rects to fake a blur falloff. Each layer now
             * gets a properly-rounded (all 4 corners) rect via
             * draw_rounded_rect, so this reads as a soft blob instead of a
             * plus-sign. */
            int layers = 5;
            for (int i = layers; i >= 1; i--) {
                double t = (double)i / layers;
                int inset = (int)(t * (app->width < app->height ? app->width : app->height) * 0.18);
                double layer_alpha = (1.0 - t) * 0.65 + 0.10;
                int lw = app->width - 2 * inset, lh = app->height - 2 * inset;
                draw_rounded_rect(app, inset, inset, lw, lh,
                                   outer_bg_radius(lw, lh), r, g, b, a, layer_alpha);
            }
            break;
        }
    }
}

/* ---------------- text drawing ---------------- */

static void draw_centered_text(app_t *app, XftFont *font, const char *text,
                                int cx, int cy, double alpha_factor, int y_offset) {
    int cr, cg, cb, ca;
    if (!parse_hex_color(app->cfg->color, &cr, &cg, &cb, &ca)) { cr = cg = cb = 255; ca = 255; }

    XGlyphInfo extents;
    XftTextExtentsUtf8(app->dpy, font, (const FcChar8 *)text, (int)strlen(text), &extents);
    int tw = extents.xOff;
    int x = cx - tw / 2;
    int y = cy + (font->ascent - font->descent) / 2;

    XRenderColor rc = make_render_color(cr, cg, cb, ca, alpha_factor);
    XftColor xc;
    xc.color = rc;
    xc.pixel = 0;
    XftDrawStringUtf8(app->xftdraw, &xc, font, x, y + y_offset, (const FcChar8 *)text, (int)strlen(text));
}

/* Restricts *text* drawing to a horizontal band; used to fake a split-flap
 * "flip" reveal without needing per-glyph geometric transforms. Must be set
 * on the XftDraw itself -- Xft manages its own internal Render Picture for
 * the drawable, separate from app->backbuf_pic, so clipping backbuf_pic has
 * no effect on XftDrawStringUtf8 output. Always paired with reset_clip()
 * before the next frame's background/label drawing. */
static void set_band_clip(app_t *app, int top, int height) {
    if (height < 0) height = 0;
    XRectangle r = { 0, (short)top, (unsigned short)app->width, (unsigned short)height };
    XftDrawSetClipRectangles(app->xftdraw, 0, 0, &r, 1);
}
static void reset_clip(app_t *app) {
    XRectangle r = { 0, 0, (unsigned short)app->width, (unsigned short)app->height };
    XftDrawSetClipRectangles(app->xftdraw, 0, 0, &r, 1);
}

/* Standard "back" easing with a small overshoot, used for the bounce style. */
static double ease_out_back(double t) {
    const double s = 1.70158;
    double t2 = t - 1.0;
    return t2 * t2 * ((s + 1.0) * t2 + s) + 1.0;
}

static const char *surprise_pool[] = {
    "Boo!", "Ta-da!", "Nice.", "Hi there!", "*poof*", "Whee!", "Surprise!"
};
#define SURPRISE_POOL_N (int)(sizeof(surprise_pool)/sizeof(surprise_pool[0]))

static void trigger_surprise(app_t *app) {
    app->surprise_active = 1;
    app->surprise_end = ts_add_ms(ts_now(), 1500);
    app->surprise_text = surprise_pool[rand() % SURPRISE_POOL_N];
}

/* Draws one segment (e.g. just "07" for seconds) at (cx, cy), handling
 * whichever scroll_style transition is in progress for it, if any. Shared
 * by render_frame's per-segment loop so flip/bounce/slide logic only lives
 * in one place regardless of how many segments the format has. */
static void draw_animated_segment(app_t *app, const char *prev, const char *cur,
                                   int *transitioning, double *transition_start,
                                   int cx, int cy, double flash_a) {
    if (!*transitioning) {
        draw_centered_text(app, app->font, cur, cx, cy, flash_a, 0);
        return;
    }

    double elapsed = app->anim_clock - *transition_start;
    double dur = app->cfg->scroll_seconds > 0 ? app->cfg->scroll_seconds : 0.0001;
    double progress = elapsed / dur;

    if (progress >= 1.0) {
        *transitioning = 0;
        draw_centered_text(app, app->font, cur, cx, cy, flash_a, 0);
    } else if (app->cfg->scroll_style == SCROLL_FLIP) {
        int fh = app->font->ascent + app->font->descent;
        int text_top = cy - fh / 2;
        if (progress < 0.5) {
            double p = progress / 0.5;
            int band_h = (int)(fh * (1.0 - p));
            set_band_clip(app, text_top + (fh - band_h) / 2, band_h);
            draw_centered_text(app, app->font, prev, cx, cy, flash_a, 0);
        } else {
            double p = (progress - 0.5) / 0.5;
            int band_h = (int)(fh * p);
            set_band_clip(app, text_top + (fh - band_h) / 2, band_h);
            draw_centered_text(app, app->font, cur, cx, cy, flash_a, 0);
        }
        reset_clip(app);
        /* brief hinge line at the crossover for a bit of mechanical feel */
        if (progress > 0.46 && progress < 0.54) {
            int cr, cg, cb, ca;
            if (!parse_hex_color(app->cfg->color, &cr, &cg, &cb, &ca)) { cr = cg = cb = 255; ca = 255; }
            XRenderColor hinge = make_render_color(cr, cg, cb, ca, 0.5 * flash_a);
            XRenderFillRectangle(app->dpy, PictOpOver, app->backbuf_pic, &hinge,
                                  cx - fh, cy - 1, fh * 2, 2);
        }
    } else if (app->cfg->scroll_style == SCROLL_BOUNCE) {
        int fh = app->font->ascent + app->font->descent;
        double ease = ease_out_back(progress);
        double alpha_ease = progress < 1.0 ? progress : 1.0; /* alpha never overshoots */
        int off_out = (int)(-progress * fh * 0.8);
        int off_in  = (int)((1.0 - ease) * fh * 0.8);
        draw_centered_text(app, app->font, prev, cx, cy, flash_a * (1 - alpha_ease), off_out);
        draw_centered_text(app, app->font, cur, cx, cy, flash_a * alpha_ease, off_in);
    } else { /* SCROLL_SLIDE */
        double ease = progress * progress * (3 - 2 * progress); /* smoothstep */
        int fh = app->font->ascent + app->font->descent;
        int off_out = (int)(-ease * fh * 0.6);
        int off_in  = (int)((1 - ease) * fh * 0.6);
        draw_centered_text(app, app->font, prev, cx, cy, flash_a * (1 - ease), off_out);
        draw_centered_text(app, app->font, cur, cx, cy, flash_a * ease, off_in);
    }
}

static void render_frame(app_t *app) {
    draw_background(app);

    int cx = app->width / 2;
    int cy = app->height / 2;
    int label_h = 0;
    if (app->cfg->label[0]) {
        label_h = app->label_font->ascent + app->label_font->descent;
        draw_centered_text(app, app->label_font, app->cfg->label, cx,
                            cy - (app->font->ascent + app->font->descent) / 2 - 4, 1.0, 0);
        cy += label_h / 4; /* nudge number down a touch to balance the label */
    }
    (void)label_h;

    double flash_a = flash_alpha_factor(app);

    if (app->surprise_active) {
        double hue = fmod(ts_diff(ts_now(), app->app_start) * 220.0, 360.0);
        /* quick HSV->RGB for a playful color cycle */
        double c = 1.0, x, m = 0.0;
        double hh = hue / 60.0;
        x = c * (1 - fabs(fmod(hh, 2) - 1));
        double rf, gf, bf;
        if (hh < 1) { rf=c; gf=x; bf=0; }
        else if (hh < 2) { rf=x; gf=c; bf=0; }
        else if (hh < 3) { rf=0; gf=c; bf=x; }
        else if (hh < 4) { rf=0; gf=x; bf=c; }
        else if (hh < 5) { rf=x; gf=0; bf=c; }
        else { rf=c; gf=0; bf=x; }
        char savedcolor[16];
        snprintf(savedcolor, sizeof(savedcolor), "%s", app->cfg->color);
        snprintf(app->cfg->color, sizeof(app->cfg->color), "#%02x%02x%02x",
                  (int)((rf+m)*255), (int)((gf+m)*255), (int)((bf+m)*255));
        draw_centered_text(app, app->font, app->surprise_text, cx, cy, 1.0, 0);
        snprintf(app->cfg->color, sizeof(app->cfg->color), "%s", savedcolor);

        if (ts_diff(ts_now(), app->surprise_end) >= 0) app->surprise_active = 0;
    } else {
        /* Lay segments out left-to-right as a centered block, using the
         * stable widest-digit slot widths computed in compute_window_size
         * so nothing jitters as digits change width. The rightmost segment
         * is the fastest-changing one (e.g. seconds in hh:mm:ss). */
        int total_w = 0;
        for (int i = 0; i < app->nsegs; i++) total_w += app->seg_slot_width[i];
        total_w += app->sep_width * (app->nsegs - 1);

        int seg_x = cx - total_w / 2;
        for (int i = 0; i < app->nsegs; i++) {
            int seg_cx = seg_x + app->seg_slot_width[i] / 2;
            int is_active = app->cfg->animate_all_segments || (i == app->nsegs - 1);
            double seg_flash_a = is_active ? flash_a : 1.0;
            draw_animated_segment(app, app->seg_prev[i], app->seg_cur[i],
                                   &app->seg_transitioning[i], &app->seg_transition_start[i],
                                   seg_cx, cy, seg_flash_a);
            seg_x += app->seg_slot_width[i];
            if (i < app->nsegs - 1) {
                draw_centered_text(app, app->font, ":", seg_x + app->sep_width / 2, cy, flash_a, 0);
                seg_x += app->sep_width;
            }
        }
    }

    XRenderComposite(app->dpy, PictOpSrc, app->backbuf_pic, None, app->win_pic,
                      0, 0, 0, 0, 0, 0, app->width, app->height);
    XFlush(app->dpy);
}

/* ---------------- countdown text update ---------------- */

static void update_display_text(app_t *app, int force_instant) {
    char newsegs[TIMEFMT_MAX_SEGMENTS][TIMEFMT_SEG_SIZE];
    int n = timefmt_render_segments(app->cfg->format, app->remaining_seconds, newsegs, TIMEFMT_MAX_SEGMENTS);

    for (int i = 0; i < n; i++) {
        if (strcmp(newsegs[i], app->seg_cur[i]) == 0) continue; /* this segment didn't change */

        if (!force_instant && app->cfg->scroll_seconds > 0) {
            snprintf(app->seg_prev[i], TIMEFMT_SEG_SIZE, "%s", app->seg_cur[i]);
            snprintf(app->seg_cur[i], TIMEFMT_SEG_SIZE, "%s", newsegs[i]);
            app->seg_transition_start[i] = app->anim_clock;
            app->seg_transitioning[i] = 1;
        } else {
            snprintf(app->seg_cur[i], TIMEFMT_SEG_SIZE, "%s", newsegs[i]);
            app->seg_transitioning[i] = 0;
        }
    }
}

/* ---------------- action execution ---------------- */

static void run_command_bg(const char *cmd) {
    if (!cmd || !cmd[0]) return;
    pid_t pid = fork();
    if (pid == 0) {
        setsid();
        execl("/bin/sh", "sh", "-c", cmd, (char *)NULL);
        _exit(127);
    }
    /* parent doesn't wait; SIGCHLD is set to SIG_IGN in xapp_run() to avoid zombies */
}

static void play_alarm(app_t *app) {
    if (!app->cfg->alarm_path[0]) return;
    /* Try a handful of common players in order; whichever exists on the
     * system will play it, and `sh -c '... || ... || ...'` short-circuits
     * past ones that aren't installed. Single quotes around the path are
     * escaped defensively in case it contains one. */
    char escaped[1024];
    int j = 0;
    for (const char *p = app->cfg->alarm_path; *p && j < (int)sizeof(escaped) - 5; p++) {
        if (*p == '\'') { escaped[j++] = '\''; escaped[j++] = '\\'; escaped[j++] = '\''; escaped[j++] = '\''; }
        else escaped[j++] = *p;
    }
    escaped[j] = '\0';

    char cmd[1536];
    snprintf(cmd, sizeof(cmd),
             "paplay '%s' || aplay '%s' || ffplay -nodisp -autoexit -loglevel quiet '%s' || play -q '%s'",
             escaped, escaped, escaped, escaped);
    run_command_bg(cmd);
}

/* Tears the app down and exits. Runs on_success only on a genuine code-0
 * exit (auto-exit-on-finish or a clean Ctrl+C), never on the right-click
 * cancel path, which calls this with code 1. Does not return. */
static void teardown_and_exit(app_t *app, int code) {
    if (code == 0 && app->cfg->on_success_cmd[0]) run_command_bg(app->cfg->on_success_cmd);
    teardown(app);
    exit(code);
}

static void apply_action(app_t *app, binding_t b) {
    switch (b.action) {
        case ACT_EXIT:
            teardown_and_exit(app, 1);
            break; /* unreachable, teardown_and_exit never returns */
        case ACT_RESET:
            app->remaining_seconds = app->total_seconds;
            app->finished = 0;
            app->paused = 0;
            app->last_tick = ts_now();
            update_display_text(app, 1);
            app->force_redraw = 1;
            break;
        case ACT_PAUSE:
            app->paused = !app->paused;
            if (!app->paused) app->last_tick = ts_now();
            app->force_redraw = 1;
            break;
        case ACT_SURPRISE:
            trigger_surprise(app);
            app->force_redraw = 1;
            break;
        case ACT_INC:
            app->remaining_seconds += b.amount;
            update_display_text(app, 1);
            app->force_redraw = 1;
            break;
        case ACT_DEC:
            app->remaining_seconds -= b.amount;
            if (app->remaining_seconds < 0) app->remaining_seconds = 0;
            update_display_text(app, 1);
            app->force_redraw = 1;
            break;
        case ACT_DRAG:
        case ACT_NONE:
        default:
            break;
    }
}

/* ---------------- event handling ---------------- */

static void begin_drag(app_t *app, int root_x, int root_y) {
    app->b1_dragging = 1;
    app->drag_off_x = root_x - app->x;
    app->drag_off_y = root_y - app->y;
    XGrabPointer(app->dpy, app->win, False,
                 PointerMotionMask | ButtonReleaseMask,
                 GrabModeAsync, GrabModeAsync, None, None, CurrentTime);
}

static void end_drag(app_t *app) {
    app->b1_dragging = 0;
    XUngrabPointer(app->dpy, CurrentTime);
}

static void handle_event(app_t *app, XEvent *ev) {
    switch (ev->type) {
        case Expose:
            app->force_redraw = 1;
            break;

        case EnterNotify:
            if (app->cfg->focus_follow && !app->has_focus) {
                Window cur_focus;
                int revert;
                XGetInputFocus(app->dpy, &cur_focus, &revert);
                /* Remember exactly what had focus before us (usually the
                 * WM-tracked focused window) so we can hand it back
                 * precisely on leave, rather than punting to PointerRoot
                 * (which click-to-focus WMs like bspwm don't treat as
                 * "give focus back to what I had focused"). */
                app->prev_focus_win = (cur_focus == app->win) ? None : cur_focus;
                app->prev_focus_revert = revert;
                app->has_focus = 1;
                XSetInputFocus(app->dpy, app->win, RevertToParent, CurrentTime);
            }
            break;

        case LeaveNotify:
            if (app->cfg->focus_follow && app->has_focus) {
                app->has_focus = 0;
                if (app->prev_focus_win != None) {
                    XSetInputFocus(app->dpy, app->prev_focus_win, app->prev_focus_revert, CurrentTime);
                } else {
                    XSetInputFocus(app->dpy, PointerRoot, RevertToPointerRoot, CurrentTime);
                }
            }
            break;

        case ButtonPress: {
            XButtonEvent *be = &ev->xbutton;
            if (be->button == Button1) {
                app->b1_down = 1;
                app->b1_dragging = 0;
                app->b1_press_time = ts_now();
                app->drag_off_x = be->x_root - app->x;
                app->drag_off_y = be->y_root - app->y;
            } else if (be->button == Button4) {
                apply_action(app, app->cfg->on_scroll_up);
            } else if (be->button == Button5) {
                apply_action(app, app->cfg->on_scroll_down);
            }
            /* Button3 (right) is handled on release, mirroring left. */
            break;
        }

        case MotionNotify: {
            if (app->alarm_active) app->alarm_active = 0;
            if (app->b1_down && app->b1_dragging) {
                app->x = ev->xmotion.x_root - app->drag_off_x;
                app->y = ev->xmotion.y_root - app->drag_off_y;
                XMoveWindow(app->dpy, app->win, app->x, app->y);
            }
            break;
        }

        case KeyPress: {
            if (app->alarm_active) app->alarm_active = 0;
            break;
        }

        case ButtonRelease: {
            XButtonEvent *be = &ev->xbutton;
            struct timespec now = ts_now();

            if (be->button == Button1) {
                if (app->b1_dragging) {
                    end_drag(app);
                } else {
                    app->b1_down = 0;
                    if (app->have_last_left_release &&
                        ts_diff(now, app->last_left_release) * 1000.0 < DOUBLE_CLICK_MS) {
                        app->left_pending = 0;
                        app->have_last_left_release = 0;
                        apply_action(app, app->cfg->on_left_dblclick);
                    } else {
                        app->left_pending = 1;
                        app->left_deadline = ts_add_ms(now, DOUBLE_CLICK_MS);
                        app->last_left_release = now;
                        app->have_last_left_release = 1;
                    }
                }
                app->b1_down = 0;
            } else if (be->button == Button3) {
                if (app->have_last_right_release &&
                    ts_diff(now, app->last_right_release) * 1000.0 < DOUBLE_CLICK_MS) {
                    app->right_pending = 0;
                    app->have_last_right_release = 0;
                    apply_action(app, app->cfg->on_right_dblclick);
                } else {
                    app->right_pending = 1;
                    app->right_deadline = ts_add_ms(now, DOUBLE_CLICK_MS);
                    app->last_right_release = now;
                    app->have_last_right_release = 1;
                }
            }
            break;
        }

        case ConfigureNotify:
        default:
            break;
    }
}

/* ---------------- main loop ---------------- */

int xapp_run(config_t *cfg) {
    app_t app_storage;
    app_t *app = &app_storage;
    memset(app, 0, sizeof(*app));
    app->cfg = cfg;
    app->total_seconds = cfg->total_seconds;
    app->remaining_seconds = cfg->total_seconds;

    signal(SIGCHLD, SIG_IGN);
    signal(SIGINT, on_sigterm);
    signal(SIGTERM, on_sigterm);
    srand((unsigned)time(NULL) ^ (unsigned)getpid());

    if (!init_x(app)) return 1;
    if (!load_fonts(app)) { teardown(app); return 1; }

    compute_window_size(app);
    compute_window_pos(app);
    if (!create_window(app)) { teardown(app); return 1; }

    app->app_start = ts_now();
    app->last_tick = app->app_start;
    app->last_frame_ts = app->app_start;
    app->anim_clock = 0.0;
    update_display_text(app, 1);

    int xfd = ConnectionNumber(app->dpy);
    app->force_redraw = 1;

    while (!g_should_quit) {
        struct timespec now = ts_now();

        /* Advance the pausable animation clock. Clamped so a long idle
         * block (we can sit in select() indefinitely) doesn't cause a huge
         * phase jump the moment something wakes us back up. */
        {
            double dt = ts_diff(now, app->last_frame_ts);
            app->last_frame_ts = now;
            if (dt < 0) dt = 0;
            if (dt > 0.5) dt = 0.5;
            int anim_allowed = app->paused ? app->cfg->animate_when_paused : app->cfg->animate_when_active;
            if (anim_allowed) app->anim_clock += dt;
        }

        /* Promote press-and-hold to a drag once the hold threshold passes. */
        if (app->b1_down && !app->b1_dragging &&
            ts_diff(now, app->b1_press_time) * 1000.0 >= HOLD_THRESHOLD_MS) {
            begin_drag(app, app->x + app->drag_off_x, app->y + app->drag_off_y);
        }

        /* Fire deferred single-click actions once their double-click grace
         * window has passed without a second click. */
        if (app->left_pending && ts_diff(now, app->left_deadline) >= 0) {
            app->left_pending = 0;
            apply_action(app, app->cfg->on_left_click);
        }
        if (app->right_pending && ts_diff(now, app->right_deadline) >= 0) {
            app->right_pending = 0;
            apply_action(app, app->cfg->on_right_click);
        }

        /* One-second timer tick. Freeze last_tick while paused so a resume
         * doesn't cause a big jump from accumulated real time. */
        if (app->paused) {
            app->last_tick = now;
        } else if (ts_diff(now, app->last_tick) >= 1.0) {
            long elapsed_secs = (long)ts_diff(now, app->last_tick);
            if (elapsed_secs < 1) elapsed_secs = 1;
            app->remaining_seconds -= elapsed_secs;
            if (app->remaining_seconds <= 0) {
                app->remaining_seconds = 0;
                if (!app->finished) {
                    app->finished = 1;
                    run_command_bg(app->cfg->on_finish_cmd);
                    if (app->cfg->alarm_path[0]) {
                        app->alarm_active = 1;
                        app->alarm_play_count = 0;
                        app->alarm_next_play = now;
                    }
                }
            }
            app->last_tick = ts_add_ms(app->last_tick, elapsed_secs * 1000.0);
            update_display_text(app, 0);
            app->force_redraw = 1;
        }

        /* Alarm playback/repeat. repeat==0 means "keep going until the user
         * interacts" (stopped from handle_event on mouse move / key press);
         * repeat>0 plays that many times then stops on its own. */
        if (app->alarm_active && ts_diff(now, app->alarm_next_play) >= 0) {
            play_alarm(app);
            app->alarm_play_count++;
            if (app->cfg->alarm_repeat > 0 && app->alarm_play_count >= app->cfg->alarm_repeat) {
                app->alarm_active = 0;
            } else {
                app->alarm_next_play = ts_add_ms(now, ALARM_REPLAY_INTERVAL_MS);
            }
        }

        /* Auto-exit only once any alarm sequence has actually concluded, so
         * an indefinite (repeat=0) alarm isn't cut off before it's heard. */
        if (app->cfg->exit_on_finish && app->finished && !app->alarm_active) {
            teardown_and_exit(app, 0);
        }

        if (app->force_redraw || animation_active(app)) {
            render_frame(app);
            app->force_redraw = 0;
        }

        /* Compute how long we can safely block in select(). */
        double timeout_s = 1.0; /* default: re-check at least once a second */
        if (app->b1_down && !app->b1_dragging) {
            double remain = HOLD_THRESHOLD_MS / 1000.0 - ts_diff(now, app->b1_press_time);
            if (remain < timeout_s) timeout_s = remain > 0 ? remain : 0;
        }
        if (app->left_pending) {
            double remain = ts_diff(app->left_deadline, now);
            if (remain < timeout_s) timeout_s = remain > 0 ? remain : 0;
        }
        if (app->right_pending) {
            double remain = ts_diff(app->right_deadline, now);
            if (remain < timeout_s) timeout_s = remain > 0 ? remain : 0;
        }
        if (animation_active(app)) {
            double frame = 1.0 / 30.0; /* cap animated redraws at ~30fps */
            if (frame < timeout_s) timeout_s = frame;
        }
        if (app->alarm_active) {
            double remain = ts_diff(app->alarm_next_play, now);
            if (remain < timeout_s) timeout_s = remain > 0 ? remain : 0;
        }
        if (!app->paused) {
            double until_tick = 1.0 - ts_diff(now, app->last_tick);
            if (until_tick < timeout_s) timeout_s = until_tick > 0 ? until_tick : 0;
        }
        if (timeout_s > MAX_IDLE_WAKE_MS / 1000.0) timeout_s = MAX_IDLE_WAKE_MS / 1000.0;
        if (timeout_s < 0) timeout_s = 0;

        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(xfd, &fds);
        struct timeval tv;
        tv.tv_sec = (time_t)timeout_s;
        tv.tv_usec = (suseconds_t)((timeout_s - tv.tv_sec) * 1e6);

        /* Idle (paused, no pending clicks, no animation, no alarm): block
         * indefinitely so the widget uses ~0 CPU while sitting still. */
        int idle = app->paused && !app->b1_down && !app->left_pending &&
                   !app->right_pending && !animation_active(app) && !app->alarm_active;
        select(xfd + 1, &fds, NULL, NULL, idle ? NULL : &tv);

        while (XPending(app->dpy)) {
            XEvent ev;
            XNextEvent(app->dpy, &ev);
            handle_event(app, &ev);
        }
    }

    teardown_and_exit(app, 0);
    return 0; /* unreachable, teardown_and_exit never returns */
}
