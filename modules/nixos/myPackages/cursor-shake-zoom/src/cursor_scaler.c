#define _POSIX_C_SOURCE 200809L

/*
 * cursor-scaler - shake the mouse cursor to magnify it (X11)
 *
 * Rendering design (see README.md for the full rationale):
 *
 *  - The overlay window is created ONCE at a fixed size big enough for
 *    max_scale and is never resized again - only ever *moved* (and only
 *    when the pointer actually moves). Resizing an unmanaged window on
 *    every animation frame is what caused the black flashing without a
 *    compositor: the geometry change gives the server a chance to show
 *    the window's (cleared/undefined) backing content before our next
 *    paint lands. Keeping geometry constant and only repainting content
 *    + reshaping the *visible region* (via XShape, at the same fixed
 *    window size) avoids that entirely.
 *
 *  - Both the raster bitmap path and the optional SVG path funnel into
 *    a single high quality "source" XRender Picture that is built once
 *    at startup (largest bitmap the theme ships, or the SVG rasterized
 *    once at max_scale resolution) and then scaled per-frame with
 *    XRender. Downscaling a high-res source looks effectively lossless,
 *    so there is no need to re-rasterize the SVG on every frame - that
 *    repeated cairo/librsvg work was the main cause of high CPU while
 *    zooming.
 *
 *  - The shape mask pixmap is also preallocated once at the fixed
 *    window size and reused (cleared + redrawn) every frame instead of
 *    being created/destroyed per frame.
 *
 *  - Growing while shaking is a plain linear ramp against wall-clock
 *    time (scale += rate * dt), so it tracks the shake continuously and
 *    smoothly with no restart artifacts. The configurable easing curve
 *    is used for exactly one thing: the single shrink-back-to-normal
 *    transition once shaking stops.
 */

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/cursorfont.h>
#include <X11/Xcursor/Xcursor.h>
#include <X11/extensions/Xrender.h>
#include <X11/extensions/Xfixes.h>
#include <X11/extensions/XInput2.h>
#include <X11/extensions/shape.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <signal.h>
#include <errno.h>
#include <sys/select.h>

#include "config.h"
#include "easing.h"
#include "svg_loader.h"

typedef struct {
    double x, y;
} Point;

typedef enum { DIR_NONE = 0, DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT } Direction;
typedef enum { CS_IDLE = 0, CS_GROWING, CS_SHRINKING } CursorState;

typedef struct {
    Config cfg;

    Display *display;
    Window   window;
    Window   root;
    int      screen;
    int      screen_w, screen_h;
    Visual  *visual;
    int      depth;
    Colormap colormap;
    int      xi_opcode;
    bool     has_shape_extension;

    /* pointer / shake tracking */
    Point     last_pos, current_pos;
    Direction last_direction;
    int       direction_changes;
    double    last_change_time;
    bool      is_shaking;
    bool      paused;

    /* animation state machine */
    CursorState state;
    double current_scale;
    double shrink_start_scale;
    double shrink_start_time;
    double last_anim_time;
    bool   needs_update;
    bool   needs_move;
    bool   window_mapped;
    bool   cursor_hidden;

    /* geometry */
    int    nominal_size;  /* on-screen size at scale 1.0 */
    int    max_size;      /* fixed window/canvas size, covers up to max_scale */
    double xhot_ratio, yhot_ratio;

    /* unified high quality cursor source (raster OR svg, doesn't matter
     * past this point - both are just an XRender Picture + resolution) */
    XcursorImage *cursor_image; /* kept for hotspot metadata */
    int           source_w, source_h;
    Picture       source_picture;
    Pixmap        source_pixmap;
    bool          use_svg;
    SvgCursor    *svg;

    XRenderPictFormat *argb_format;
    XRenderPictFormat *a1_format;
    Picture             window_picture;

    /* preallocated once, reused every frame */
    Pixmap  mask_pixmap;
    Picture mask_picture;

    bool has_compositor;
    bool use_shape;
} CursorScaler;

static CursorScaler *g_scaler = NULL;
static volatile sig_atomic_t g_pause_requested = 0;
static volatile sig_atomic_t g_quit_requested = 0;

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */

static double get_time(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1000000000.0;
}

static bool detect_compositor(Display *d, int screen) {
    char prop[32];
    snprintf(prop, sizeof(prop), "_NET_WM_CM_S%d", screen);
    Atom atom = XInternAtom(d, prop, False);
    return XGetSelectionOwner(d, atom) != None;
}

static void on_signal_quit(int signum) { (void)signum; g_quit_requested = 1; }
static void on_signal_pause(int signum) { (void)signum; g_pause_requested = 1; }

static Direction get_movement_direction(Point delta, double threshold) {
    if (fabs(delta.x) <= threshold && fabs(delta.y) <= threshold) return DIR_NONE;
    if (fabs(delta.x) > fabs(delta.y)) return delta.x > 0 ? DIR_RIGHT : DIR_LEFT;
    return delta.y > 0 ? DIR_DOWN : DIR_UP;
}

/* Best-effort, cheap check for "is the focused window fullscreen (e.g. a
 * game)". Only ever called right as a shake is about to engage - not
 * per frame - so the couple of round trips it costs are irrelevant. */
static bool active_window_is_fullscreen(Display *d, Window root, int screen_w, int screen_h) {
    Atom net_active = XInternAtom(d, "_NET_ACTIVE_WINDOW", True);
    if (net_active == None) return false;

    Atom actual_type;
    int actual_format;
    unsigned long nitems, bytes_after;
    unsigned char *prop = NULL;
    Window active = None;

    if (XGetWindowProperty(d, root, net_active, 0, 1, False, XA_WINDOW,
                            &actual_type, &actual_format, &nitems, &bytes_after, &prop) == Success && prop) {
        if (nitems > 0) active = *(Window *)prop;
        XFree(prop);
    }
    if (active == None) return false;

    /* heuristic 1: EWMH fullscreen state */
    Atom net_wm_state = XInternAtom(d, "_NET_WM_STATE", True);
    Atom fullscreen_atom = XInternAtom(d, "_NET_WM_STATE_FULLSCREEN", True);
    if (net_wm_state != None && fullscreen_atom != None) {
        prop = NULL;
        if (XGetWindowProperty(d, active, net_wm_state, 0, 1024, False, XA_ATOM,
                                &actual_type, &actual_format, &nitems, &bytes_after, &prop) == Success && prop) {
            Atom *atoms = (Atom *)prop;
            for (unsigned long i = 0; i < nitems; i++) {
                if (atoms[i] == fullscreen_atom) { XFree(prop); return true; }
            }
            XFree(prop);
        }
    }

    /* heuristic 2: borderless window whose geometry exactly covers the
     * screen (common for games that don't bother setting the EWMH
     * fullscreen state) */
    Window child;
    int x, y;
    unsigned int w, h, bw, depth;
    if (XGetGeometry(d, active, &child, &x, &y, &w, &h, &bw, &depth)) {
        int rx = 0, ry = 0;
        Window dummy_child;
        if (XTranslateCoordinates(d, active, root, 0, 0, &rx, &ry, &dummy_child)) {
            if (rx <= 0 && ry <= 0 && (int)w >= screen_w && (int)h >= screen_h) {
                return true;
            }
        }
    }

    return false;
}

/* ------------------------------------------------------------------ */
/* SVG auto-discovery                                                   */
/* ------------------------------------------------------------------ */

static bool try_path(const char *fmt, const char *a, const char *b, const char *c,
                      char *out, size_t out_len) {
    snprintf(out, out_len, fmt, a, b, c);
    FILE *f = fopen(out, "r");
    if (f) { fclose(f); return true; }
    return false;
}

/* Best-effort search for a source SVG matching the active cursor theme
 * and cursor name. Standard compiled Xcursor themes don't ship SVGs, so
 * this only succeeds if the user has the theme's source tree installed
 * alongside it. Returns true and fills `out` on success. */
static bool find_cursor_svg(const char *theme, const char *cursor_name,
                             char *out, size_t out_len) {
    if (!theme || !*theme) return false;

    const char *home = getenv("HOME");
    char base_icons[512], base_local[512];
    if (home) {
        snprintf(base_icons, sizeof(base_icons), "%s/.icons", home);
        snprintf(base_local, sizeof(base_local), "%s/.local/share/icons", home);
    } else {
        base_icons[0] = base_local[0] = '\0';
    }

    const char *bases[] = {
        base_icons, base_local, "/usr/share/icons", "/usr/local/share/icons"
    };
    const char *patterns[] = {
        "%s/%s/svg/%s.svg",
        "%s/%s/cursors_svg/%s.svg",
        "%s/%s/src/%s.svg",
        "%s/%s/%s.svg",
    };

    for (size_t bi = 0; bi < sizeof(bases) / sizeof(bases[0]); bi++) {
        if (!bases[bi][0]) continue;
        for (size_t pi = 0; pi < sizeof(patterns) / sizeof(patterns[0]); pi++) {
            if (try_path(patterns[pi], bases[bi], theme, cursor_name, out, out_len))
                return true;
        }
    }
    return false;
}

/* ------------------------------------------------------------------ */
/* rendering                                                            */
/* ------------------------------------------------------------------ */

static Picture upload_argb_to_picture(CursorScaler *s, unsigned char *argb,
                                       int w, int h, Pixmap *out_pixmap) {
    /* Use the root window as the reference drawable, not s->window - this
     * is called from load_cursor_source() before the overlay window has
     * been created (we need to know the cursor's max_size before we can
     * size that window), so s->window would still be None here. */
    Pixmap pixmap = XCreatePixmap(s->display, s->root, (unsigned)w, (unsigned)h, 32);
    GC gc = XCreateGC(s->display, pixmap, 0, NULL);

    XImage *image = XCreateImage(s->display, s->visual, 32, ZPixmap, 0,
                                  (char *)argb, (unsigned)w, (unsigned)h, 32, 0);
    XPutImage(s->display, pixmap, gc, image, 0, 0, 0, 0, (unsigned)w, (unsigned)h);
    image->data = NULL; /* we don't own this buffer - don't let XDestroyImage free it */
    XDestroyImage(image);
    XFreeGC(s->display, gc);

    Picture picture = XRenderCreatePicture(s->display, pixmap, s->argb_format, 0, NULL);
    XRenderSetPictureFilter(s->display, picture, s->cfg.filter, NULL, 0);

    if (out_pixmap) *out_pixmap = pixmap;
    else XFreePixmap(s->display, pixmap);

    return picture;
}

static void hide_system_cursor(CursorScaler *s) {
    if (!s->cursor_hidden) {
        XFixesHideCursor(s->display, s->root);
        s->cursor_hidden = true;
    }
}

static void show_system_cursor(CursorScaler *s) {
    if (s->cursor_hidden) {
        XFixesShowCursor(s->display, s->root);
        s->cursor_hidden = false;
    }
}

static void render_cursor(CursorScaler *s) {
    bool want_visible = (s->state != CS_IDLE);

    if (!want_visible) {
        if (s->window_mapped) {
            XUnmapWindow(s->display, s->window);
            s->window_mapped = false;
        }
        show_system_cursor(s);
        return;
    }

    /* Re-check compositor presence right as a new zoom session begins
     * (cheap - happens once per shake, not per frame) so we adapt if a
     * compositor was started/stopped since the last time we zoomed. */
    if (!s->window_mapped && s->cfg.shape_mode == SHAPE_AUTO) {
        s->has_compositor = detect_compositor(s->display, s->screen);
        s->use_shape = s->has_shape_extension && !s->has_compositor;
    }

    hide_system_cursor(s);

    int scaled_size = (int)lround(s->nominal_size * s->current_scale);
    if (scaled_size < 1) scaled_size = 1;
    if (scaled_size > s->max_size) scaled_size = s->max_size;

    int local_x = (int)lround(s->xhot_ratio * (s->max_size - scaled_size));
    int local_y = (int)lround(s->yhot_ratio * (s->max_size - scaled_size));

    if (s->needs_move || !s->window_mapped) {
        int window_x = (int)lround(s->current_pos.x - s->max_size * s->xhot_ratio);
        int window_y = (int)lround(s->current_pos.y - s->max_size * s->yhot_ratio);
        XMoveWindow(s->display, s->window, window_x, window_y);
        s->needs_move = false;
    }

    XTransform transform;
    memset(&transform, 0, sizeof(transform));
    double sx = (double)s->source_w / (double)scaled_size;
    double sy = (double)s->source_h / (double)scaled_size;
    transform.matrix[0][0] = XDoubleToFixed(sx);
    transform.matrix[1][1] = XDoubleToFixed(sy);
    transform.matrix[2][2] = XDoubleToFixed(1.0);
    XRenderSetPictureTransform(s->display, s->source_picture, &transform);

    const XRenderColor clear = {0, 0, 0, 0};

    if (!s->use_shape) {
        /* No shape cutout (compositor is doing alpha blending for us) -
         * explicitly clear the whole fixed-size window first so nothing
         * from a previous, larger frame bleeds through. */
        XRenderFillRectangle(s->display, PictOpSrc, s->window_picture, &clear,
                              0, 0, (unsigned)s->max_size, (unsigned)s->max_size);
    }

    XRenderComposite(s->display, PictOpSrc, s->source_picture, None, s->window_picture,
                      0, 0, 0, 0, local_x, local_y, (unsigned)scaled_size, (unsigned)scaled_size);

    if (s->use_shape) {
        XRenderFillRectangle(s->display, PictOpSrc, s->mask_picture, &clear,
                              0, 0, (unsigned)s->max_size, (unsigned)s->max_size);
        XRenderComposite(s->display, PictOpSrc, s->source_picture, None, s->mask_picture,
                          0, 0, 0, 0, local_x, local_y, (unsigned)scaled_size, (unsigned)scaled_size);
        XShapeCombineMask(s->display, s->window, ShapeBounding, 0, 0, s->mask_pixmap, ShapeSet);
    }

    if (!s->window_mapped) {
        XMapWindow(s->display, s->window);
        s->window_mapped = true;
    }
}

/* ------------------------------------------------------------------ */
/* shake detection / animation state machine                            */
/* ------------------------------------------------------------------ */

static void handle_motion(CursorScaler *s, double x, double y) {
    if (s->paused) return;

    Point current_pos = {x, y};
    Point delta = {current_pos.x - s->last_pos.x, current_pos.y - s->last_pos.y};
    s->current_pos = current_pos;

    if (s->state != CS_IDLE) {
        s->needs_move = true;
        s->needs_update = true;
    }

    double distance = sqrt(delta.x * delta.x + delta.y * delta.y);
    if (distance < 1.0) {
        s->last_pos = current_pos;
        return;
    }

    double now = get_time();

    if (now - s->last_change_time > s->cfg.shake_timeout) {
        s->direction_changes = 0;
    }

    Direction dir = get_movement_direction(delta, s->cfg.movement_threshold);
    if (dir != DIR_NONE && dir != s->last_direction) {
        if (now - s->last_change_time < s->cfg.shake_timeout) {
            s->direction_changes++;
        } else {
            s->direction_changes = 1;
        }
        s->last_change_time = now;
        s->last_direction = dir;
    }

    if (s->direction_changes >= s->cfg.shake_threshold) {
        if (!s->is_shaking && s->cfg.disable_in_fullscreen &&
            active_window_is_fullscreen(s->display, s->root, s->screen_w, s->screen_h)) {
            /* Refuse to engage while a fullscreen app (e.g. a game) is
             * focused. Reset the streak so a deliberate shake right
             * after alt-tabbing out still works normally. */
            s->direction_changes = 0;
            s->last_pos = current_pos;
            return;
        }

        s->is_shaking = true;
        if (s->state != CS_GROWING) {
            s->state = CS_GROWING;
            s->last_anim_time = now; /* avoid a dt spike coming from idle */
        }
        s->needs_update = true;
    }

    s->last_pos = current_pos;
}

static void check_shake_timeout(CursorScaler *s) {
    if (!s->is_shaking) return;
    double now = get_time();
    if (now - s->last_change_time > s->cfg.shake_timeout) {
        s->is_shaking = false;
        s->direction_changes = 0;
        if (s->state == CS_GROWING) {
            if (s->current_scale > s->cfg.min_scale + 1e-6) {
                s->state = CS_SHRINKING;
                s->shrink_start_scale = s->current_scale;
                s->shrink_start_time = now;
            } else {
                s->state = CS_IDLE;
            }
            s->needs_update = true;
        }
    }
}

static void update_animation(CursorScaler *s) {
    double now = get_time();

    switch (s->state) {
        case CS_GROWING: {
            double dt = now - s->last_anim_time;
            if (dt < 0) dt = 0;
            if (dt > 0.25) dt = 0.25; /* clamp against scheduling hiccups */
            s->current_scale = fmin(s->cfg.max_scale, s->current_scale + s->cfg.zoom_in_rate * dt);
            s->last_anim_time = now;
            s->needs_update = true;
            break;
        }
        case CS_SHRINKING: {
            double dur = s->cfg.zoom_out_duration;
            double t = dur > 0.0 ? (now - s->shrink_start_time) / dur : 1.0;
            if (t >= 1.0) {
                s->current_scale = s->cfg.min_scale;
                s->state = CS_IDLE;
            } else {
                double eased = ease_apply(s->cfg.easing, t);
                s->current_scale = s->shrink_start_scale +
                                    (s->cfg.min_scale - s->shrink_start_scale) * eased;
            }
            s->needs_update = true;
            break;
        }
        case CS_IDLE:
        default:
            break;
    }
}

static void force_idle(CursorScaler *s) {
    s->state = CS_IDLE;
    s->is_shaking = false;
    s->direction_changes = 0;
    s->current_scale = s->cfg.min_scale;
    s->needs_update = true;
}

/* ------------------------------------------------------------------ */
/* setup                                                                */
/* ------------------------------------------------------------------ */

static void load_cursor_source(CursorScaler *s) {
    const char *theme = s->cfg.cursor_theme[0] ? s->cfg.cursor_theme : getenv("XCURSOR_THEME");
    int size_hint = s->cfg.cursor_size > 0 ? s->cfg.cursor_size : 512; /* 512 = "largest you have" */

    s->cursor_image = XcursorLibraryLoadImage(s->cfg.cursor_name, theme, size_hint);
    if (!s->cursor_image) {
        fprintf(stderr, "cursor-scaler: failed to load cursor '%s' (theme: %s)\n",
                s->cfg.cursor_name, theme ? theme : "(default)");
        exit(1);
    }

    fprintf(stderr, "cursor-scaler: loaded '%s' bitmap at %ux%u px%s\n",
            s->cfg.cursor_name, s->cursor_image->width, s->cursor_image->height,
            s->cfg.cursor_size > 0 ? "" : " (largest available)");

    /* Prefer whatever size the user's environment actually configures
     * for the real cursor (XCURSOR_SIZE), falling back to the Xcursor
     * library default. Getting this right matters: it's the size our
     * replacement window renders at when scale == 1.0, and a mismatch
     * against the *real* on-screen cursor size is what makes the swap
     * from system cursor to our overlay look like a "shrink" the
     * instant a zoom starts. */
    if (s->cfg.cursor_size > 0) {
        s->nominal_size = s->cfg.cursor_size;
    } else {
        const char *env_size = getenv("XCURSOR_SIZE");
        int parsed = env_size ? atoi(env_size) : 0;
        s->nominal_size = parsed > 0 ? parsed : XcursorGetDefaultSize(s->display);
        if (s->nominal_size <= 0) s->nominal_size = 24;
    }

    s->xhot_ratio = (double)s->cursor_image->xhot / (double)s->cursor_image->width;
    s->yhot_ratio = (double)s->cursor_image->yhot / (double)s->cursor_image->height;

    s->max_size = (int)lround(s->nominal_size * s->cfg.max_scale);
    if (s->max_size < s->nominal_size) s->max_size = s->nominal_size;
    if (s->max_size > 2048) {
        fprintf(stderr, "cursor-scaler: clamping max render size %dpx -> 2048px "
                         "(max_scale too large for nominal cursor size)\n", s->max_size);
        s->max_size = 2048;
    }

    /* SVG lossless path: rasterize once, right now, at max_size. Every
     * frame afterwards just downscales this via XRender, which is both
     * cheap and visually indistinguishable from re-rendering the vector
     * at each size. */
    if (!s->cfg.disable_svg) {
        char path_buf[512];
        const char *svg_path = NULL;

        if (s->cfg.svg_path[0]) {
            svg_path = s->cfg.svg_path;
        } else if (theme && find_cursor_svg(theme, s->cfg.cursor_name, path_buf, sizeof(path_buf))) {
            svg_path = path_buf;
        }

        if (svg_path) {
            if (!svg_support_built()) {
                fprintf(stderr, "cursor-scaler: found/configured SVG '%s' but this build "
                                 "was compiled without librsvg support - ignoring\n", svg_path);
            } else {
                s->svg = svg_cursor_load(svg_path);
                if (s->svg) {
                    unsigned char *buf = svg_cursor_render(s->svg, s->max_size, s->max_size);
                    if (buf) {
                        Pixmap pixmap;
                        s->source_picture = upload_argb_to_picture(s, buf, s->max_size, s->max_size, &pixmap);
                        s->source_pixmap = pixmap;
                        s->source_w = s->source_h = s->max_size;
                        s->use_svg = true;
                        free(buf);
                        fprintf(stderr, "cursor-scaler: using SVG '%s', rasterized once at %dpx "
                                         "for lossless zoom\n", svg_path, s->max_size);
                    } else {
                        fprintf(stderr, "cursor-scaler: SVG '%s' failed to rasterize, "
                                         "falling back to bitmap scaling\n", svg_path);
                    }
                } else {
                    fprintf(stderr, "cursor-scaler: failed to load SVG '%s', "
                                     "falling back to bitmap scaling\n", svg_path);
                }
            }
        }
    }

    if (!s->use_svg) {
        Pixmap pixmap;
        s->source_picture = upload_argb_to_picture(
            s, (unsigned char *)s->cursor_image->pixels,
            (int)s->cursor_image->width, (int)s->cursor_image->height, &pixmap);
        s->source_pixmap = pixmap;
        s->source_w = (int)s->cursor_image->width;
        s->source_h = (int)s->cursor_image->height;
    }
}

int main(int argc, char **argv) {
    CursorScaler scaler;
    memset(&scaler, 0, sizeof(scaler));
    g_scaler = &scaler;

    config_set_defaults(&scaler.cfg);

    char default_conf[512];
    config_default_path(default_conf, sizeof(default_conf));
    config_load_file(&scaler.cfg, default_conf); /* silently ignored if missing */

    int rc = config_parse_args(&scaler.cfg, argc, argv);
    if (rc != 0) return rc > 0 ? 0 : 1;

    signal(SIGINT, on_signal_quit);
    signal(SIGTERM, on_signal_quit);
    signal(SIGHUP, on_signal_quit);
    signal(SIGUSR1, on_signal_pause);

    scaler.display = XOpenDisplay(NULL);
    if (!scaler.display) {
        fprintf(stderr, "cursor-scaler: cannot open X display\n");
        return 1;
    }
    scaler.screen = DefaultScreen(scaler.display);
    scaler.root = DefaultRootWindow(scaler.display);
    scaler.screen_w = DisplayWidth(scaler.display, scaler.screen);
    scaler.screen_h = DisplayHeight(scaler.display, scaler.screen);

    int event, error;
    if (!XQueryExtension(scaler.display, "XInputExtension", &scaler.xi_opcode, &event, &error)) {
        fprintf(stderr, "cursor-scaler: XInput extension not available\n");
        return 1;
    }
    int major = 2, minor = 0;
    if (XIQueryVersion(scaler.display, &major, &minor) != Success) {
        fprintf(stderr, "cursor-scaler: XInput2 not available\n");
        return 1;
    }
    scaler.has_shape_extension = XShapeQueryExtension(scaler.display, &event, &error);
    if (!scaler.has_shape_extension) {
        fprintf(stderr, "cursor-scaler: XShape extension not available "
                         "(no-compositor fallback will not work correctly)\n");
    }

    scaler.has_compositor = detect_compositor(scaler.display, scaler.screen);
    scaler.use_shape = scaler.has_shape_extension &&
                        ((scaler.cfg.shape_mode == SHAPE_FORCE_ON) ||
                         (scaler.cfg.shape_mode == SHAPE_AUTO && !scaler.has_compositor));
    fprintf(stderr, "cursor-scaler: compositor %s, shape-cutout mode %s\n",
            scaler.has_compositor ? "detected" : "not detected",
            scaler.use_shape ? "ON" : "off");

    /* find an ARGB visual for the overlay window */
    XVisualInfo vinfo_template = {.screen = scaler.screen};
    int nvisuals;
    XVisualInfo *vinfo = XGetVisualInfo(scaler.display, VisualScreenMask, &vinfo_template, &nvisuals);

    Visual *argb_visual = NULL;
    for (int i = 0; i < nvisuals; i++) {
        XRenderPictFormat *format = XRenderFindVisualFormat(scaler.display, vinfo[i].visual);
        if (format && format->type == PictTypeDirect && format->direct.alphaMask) {
            argb_visual = vinfo[i].visual;
            scaler.depth = vinfo[i].depth;
            break;
        }
    }
    XFree(vinfo);

    if (!argb_visual) {
        fprintf(stderr, "cursor-scaler: no ARGB visual found\n");
        return 1;
    }
    scaler.visual = argb_visual;
    scaler.argb_format = XRenderFindVisualFormat(scaler.display, scaler.visual);
    scaler.a1_format = XRenderFindStandardFormat(scaler.display, PictStandardA1);

    scaler.colormap = XCreateColormap(scaler.display, scaler.root, argb_visual, AllocNone);

    /* Load the cursor source first so we know max_size before creating
     * the (fixed-size, never-resized) overlay window. */
    load_cursor_source(&scaler);

    XSetWindowAttributes attrs = {
        .override_redirect = True,
        .background_pixel = 0,
        .border_pixel = 0,
        .colormap = scaler.colormap,
    };
    scaler.window = XCreateWindow(scaler.display, scaler.root,
                                   0, 0, (unsigned)scaler.max_size, (unsigned)scaler.max_size,
                                   0, scaler.depth, InputOutput, scaler.visual,
                                   CWOverrideRedirect | CWBackPixel | CWBorderPixel | CWColormap,
                                   &attrs);

    XClassHint *class_hint = XAllocClassHint();
    if (class_hint) {
        class_hint->res_name = (char *)"cursor-scaler";
        class_hint->res_class = (char *)"CursorScaler";
        XSetClassHint(scaler.display, scaler.window, class_hint);
        XFree(class_hint);
    }
    XStoreName(scaler.display, scaler.window, "Cursor Scaler");

    scaler.window_picture = XRenderCreatePicture(scaler.display, scaler.window,
                                                  scaler.argb_format, 0, NULL);

    if (scaler.has_shape_extension) {
        scaler.mask_pixmap = XCreatePixmap(scaler.display, scaler.window,
                                            (unsigned)scaler.max_size, (unsigned)scaler.max_size, 1);
        scaler.mask_picture = XRenderCreatePicture(scaler.display, scaler.mask_pixmap,
                                                     scaler.a1_format, 0, NULL);
        if (!scaler.use_shape) {
            /* make sure the window starts out with its default (full,
             * rectangular) shape if we're not using the cutout */
            XShapeCombineMask(scaler.display, scaler.window, ShapeBounding, 0, 0, None, ShapeSet);
        }
    }

    scaler.state = CS_IDLE;
    scaler.current_scale = scaler.cfg.min_scale;
    scaler.last_change_time = get_time();
    scaler.cursor_hidden = false;
    scaler.window_mapped = false;

    XIEventMask mask;
    mask.deviceid = XIAllMasterDevices;
    mask.mask_len = XIMaskLen(XI_RawMotion);
    mask.mask = calloc((size_t)mask.mask_len, sizeof(char));
    XISetMask(mask.mask, XI_RawMotion);
    XISelectEvents(scaler.display, scaler.root, &mask, 1);
    free(mask.mask);

    Window root_return, child_return;
    int root_x, root_y, win_x, win_y;
    unsigned int mask_return;
    XQueryPointer(scaler.display, scaler.root, &root_return, &child_return,
                  &root_x, &root_y, &win_x, &win_y, &mask_return);
    scaler.last_pos.x = root_x;
    scaler.last_pos.y = root_y;
    scaler.current_pos = scaler.last_pos;

    int x11_fd = ConnectionNumber(scaler.display);
    XEvent ev;

    while (!g_quit_requested) {
        if (g_pause_requested) {
            g_pause_requested = 0;
            scaler.paused = !scaler.paused;
            fprintf(stderr, "cursor-scaler: %s\n", scaler.paused ? "paused" : "resumed");
            if (scaler.paused) force_idle(&scaler);
        }

        bool active = (scaler.state != CS_IDLE);

        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(x11_fd, &fds);

        struct timespec timeout;
        struct timespec *timeout_ptr = NULL;
        if (active) {
            int fps = scaler.cfg.fps > 0 ? scaler.cfg.fps : 60;
            long ns = 1000000000L / fps;
            timeout.tv_sec = ns / 1000000000L;
            timeout.tv_nsec = ns % 1000000000L;
            timeout_ptr = &timeout;
        }
        /* else: block indefinitely - true zero CPU usage at idle */

        int ret = pselect(x11_fd + 1, &fds, NULL, NULL, timeout_ptr, NULL);
        if (ret < 0) {
            if (errno == EINTR) continue; /* woken by a signal - loop and handle it above */
            break;
        }

        bool got_motion = false;
        if (ret > 0 && FD_ISSET(x11_fd, &fds)) {
            while (XPending(scaler.display)) {
                XNextEvent(scaler.display, &ev);
                XGenericEventCookie *cookie = &ev.xcookie;
                if (cookie->type == GenericEvent && cookie->extension == scaler.xi_opcode &&
                    XGetEventData(scaler.display, cookie)) {
                    if (cookie->evtype == XI_RawMotion) got_motion = true;
                    XFreeEventData(scaler.display, cookie);
                }
            }
        }

        if (got_motion && !scaler.paused) {
            /* Coalesce: however many raw motion events arrived in this
             * batch, we only need the pointer's final position. */
            XQueryPointer(scaler.display, scaler.root, &root_return, &child_return,
                          &root_x, &root_y, &win_x, &win_y, &mask_return);
            handle_motion(&scaler, root_x, root_y);
        }

        if (active && !scaler.paused) {
            check_shake_timeout(&scaler);
            update_animation(&scaler);
        }

        if (scaler.needs_update) {
            render_cursor(&scaler);
            scaler.needs_update = false;
            XFlush(scaler.display);
        }
    }

    if (scaler.cursor_hidden) XFixesShowCursor(scaler.display, scaler.root);
    XFlush(scaler.display);
    XCloseDisplay(scaler.display);
    return 0;
}
