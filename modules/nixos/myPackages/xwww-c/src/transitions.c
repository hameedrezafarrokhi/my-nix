#include "transitions.h"
#include <math.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

tparams_t tparams_defaults(void) {
    tparams_t p;
    p.wave_amp = 50;
    p.wave_length = 200;
    p.pixelate_size = 64;
    p.blinds_count = 12;
    p.checker_size = 48;
    p.seed = 0.4217;
    return p;
}

/* deterministic per-cell/pixel hash -> [0,1) */
static double hash01(int x, int y, double seed) {
    uint32_t h = (uint32_t)(x * 374761393 + y * 668265263);
    h ^= (uint32_t)(seed * 4294967295.0);
    h = (h ^ (h >> 13)) * 1274126177u;
    h ^= h >> 16;
    return (h & 0xFFFFFFu) / (double)0xFFFFFFu;
}

static inline double smoothstep(double a, double b, double x) {
    if (a == b) return x < a ? 0.0 : 1.0;
    double u = (x - a) / (b - a);
    if (u < 0) u = 0;
    if (u > 1) u = 1;
    return u * u * (3 - 2 * u);
}

/* ---------------------------------------------------------------- fade */
static void fx_fade(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    (void)p;
    for (int y = r0; y < r1; y++)
        for (int x = 0; x < from->w; x++) {
            size_t i = (size_t)y * from->w + x;
            out->pix[i] = px_lerp(from->pix[i], to->pix[i], t);
        }
}

/* ---------------------------------------------------------- wipe (4 dir) */
static void wipe_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                          int r0, int r1, int dir) {
    int w = from->w, h = from->h;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int reveal;
            switch (dir) {
                case 0: reveal = x < (int)(w * t); break;          /* left->right */
                case 1: reveal = x >= (int)(w * (1 - t)); break;   /* right->left */
                case 2: reveal = y < (int)(h * t); break;          /* top->bottom */
                default: reveal = y >= (int)(h * (1 - t)); break;  /* bottom->top */
            }
            size_t i = (size_t)y * w + x;
            out->pix[i] = reveal ? to->pix[i] : from->pix[i];
        }
    }
}
static void fx_wipe_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; wipe_generic(f, t2, o, t, r0, r1, 0); }
static void fx_wipe_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { (void)p; wipe_generic(f, t2, o, t, r0, r1, 1); }
static void fx_wipe_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; wipe_generic(f, t2, o, t, r0, r1, 2); }
static void fx_wipe_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { (void)p; wipe_generic(f, t2, o, t, r0, r1, 3); }

/* --------------------------------------------------- slide (new covers old) */
static void slide_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                           int r0, int r1, int dir) {
    int w = from->w, h = from->h;
    int off_x = 0, off_y = 0;
    switch (dir) {
        case 0: off_x = (int)lround((1 - t) * w); break;  /* slide-right: enters from left */
        case 1: off_x = -(int)lround((1 - t) * w); break; /* slide-left: enters from right */
        case 2: off_y = (int)lround((1 - t) * h); break;  /* slide-down: enters from top */
        default: off_y = -(int)lround((1 - t) * h); break;/* slide-up: enters from bottom */
    }
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int sx = x - off_x, sy = y - off_y;
            size_t i = (size_t)y * w + x;
            if (sx >= 0 && sx < w && sy >= 0 && sy < h)
                out->pix[i] = to->pix[(size_t)sy * w + sx];
            else
                out->pix[i] = from->pix[i];
        }
    }
}
static void fx_slide_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { (void)p; slide_generic(f, t2, o, t, r0, r1, 0); }
static void fx_slide_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; slide_generic(f, t2, o, t, r0, r1, 1); }
static void fx_slide_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; slide_generic(f, t2, o, t, r0, r1, 2); }
static void fx_slide_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { (void)p; slide_generic(f, t2, o, t, r0, r1, 3); }

/* --------------------------------------------------- push (both move together)
 * Model P0 and P1 as glued into one strip of length 2N: [P0 | P1]. A window
 * of width N slides across it as `offset` goes 0..N, so at t=0 we see P0
 * exactly and at t=1 we see P1 exactly, with no seam. push-right/push-up are
 * just push-left/push-down with (from,to) swapped and t replaced by 1-t. */
static void push_horiz(const buf_t *p0, const buf_t *p1, buf_t *out, double offset01,
                        int r0, int r1) {
    int w = out->w;
    int off = (int)lround(offset01 * w);
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int pos = x + off;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (pos < w) ? p0->pix[(size_t)y * w + pos]
                                     : p1->pix[(size_t)y * w + (pos - w)];
        }
    }
}
static void push_vert(const buf_t *p0, const buf_t *p1, buf_t *out, double offset01,
                       int r0, int r1) {
    int w = out->w, h = out->h;
    int off = (int)lround(offset01 * h);
    for (int y = r0; y < r1; y++) {
        int pos = y + off;
        const buf_t *src = (pos < h) ? p0 : p1;
        int sy = (pos < h) ? pos : pos - h;
        memcpy(&out->pix[(size_t)y * w], &src->pix[(size_t)sy * w], (size_t)w * sizeof(uint32_t));
    }
}
static void fx_push_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; push_horiz(f, t2, o, t, r0, r1); }
static void fx_push_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { (void)p; push_horiz(t2, f, o, 1 - t, r0, r1); }
static void fx_push_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; push_vert(f, t2, o, t, r0, r1); }
static void fx_push_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { (void)p; push_vert(t2, f, o, 1 - t, r0, r1); }

/* --------------------------------------------------------- oblique (diagonal) */
static void oblique_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                             int r0, int r1, int right) {
    int w = from->w, h = from->h;
    double diag = w + h;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double d = right ? (x + y) : ((w - x) + y);
            int reveal = d < t * diag;
            size_t i = (size_t)y * w + x;
            out->pix[i] = reveal ? to->pix[i] : from->pix[i];
        }
    }
}
static void fx_oblique_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { (void)p; oblique_generic(f, t2, o, t, r0, r1, 1); }
static void fx_oblique_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; oblique_generic(f, t2, o, t, r0, r1, 0); }

/* --------------------------------------------------------------- emerge */
/* Grows a solid rectangle of `to` in from the given edge (distinct from
 * wipe only in name/edge orientation, kept for feature parity with the
 * original tool's "emerge-right"/"emerge-down"). */
static void fx_emerge_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { (void)p; wipe_generic(f, t2, o, t, r0, r1, 1); }
static void fx_emerge_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; wipe_generic(f, t2, o, t, r0, r1, 0); }
static void fx_emerge_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { (void)p; wipe_generic(f, t2, o, t, r0, r1, 3); }
static void fx_emerge_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { (void)p; wipe_generic(f, t2, o, t, r0, r1, 2); }

/* ------------------------------------------------------------- circles */
static void fx_circle_out(const buf_t *from, const buf_t *to, buf_t *out, double t,
                           const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double maxr = sqrt(cx * cx + cy * cy);
    double radius = t * maxr;
    for (int y = r0; y < r1; y++) {
        double dy = y - cy;
        for (int x = 0; x < w; x++) {
            double dx = x - cx;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (sqrt(dx * dx + dy * dy) <= radius) ? to->pix[i] : from->pix[i];
        }
    }
}
static void fx_circle_in(const buf_t *from, const buf_t *to, buf_t *out, double t,
                          const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double maxr = sqrt(cx * cx + cy * cy);
    double radius = (1 - t) * maxr;
    for (int y = r0; y < r1; y++) {
        double dy = y - cy;
        for (int x = 0; x < w; x++) {
            double dx = x - cx;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (sqrt(dx * dx + dy * dy) <= radius) ? from->pix[i] : to->pix[i];
        }
    }
}
/* soft-edged variant of circle-out, feathered boundary */
static void fx_grow_center(const buf_t *from, const buf_t *to, buf_t *out, double t,
                            const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double maxr = sqrt(cx * cx + cy * cy);
    double radius = t * maxr;
    double band = maxr * 0.02 + 1;
    for (int y = r0; y < r1; y++) {
        double dy = y - cy;
        for (int x = 0; x < w; x++) {
            double dx = x - cx;
            double d = sqrt(dx * dx + dy * dy);
            double a = smoothstep(radius + band, radius - band, d); /* 1 inside, 0 outside */
            size_t i = (size_t)y * w + x;
            out->pix[i] = px_lerp(from->pix[i], to->pix[i], a);
        }
    }
}

/* -------------------------------------------------------------- diamond */
static void fx_diamond(const buf_t *from, const buf_t *to, buf_t *out, double t,
                        const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double maxd = cx + cy;
    double radius = t * maxd;
    for (int y = r0; y < r1; y++) {
        double dy = fabs(y - cy);
        for (int x = 0; x < w; x++) {
            double dx = fabs(x - cx);
            size_t i = (size_t)y * w + x;
            out->pix[i] = (dx + dy <= radius) ? to->pix[i] : from->pix[i];
        }
    }
}

/* ----------------------------------------------------------------- clock */
static void fx_clock(const buf_t *from, const buf_t *to, buf_t *out, double t,
                      const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double sweep = t * 2 * M_PI;
    for (int y = r0; y < r1; y++) {
        double dy = y - cy;
        for (int x = 0; x < w; x++) {
            double dx = x - cx;
            double ang = atan2(dx, -dy); /* 0 at 12 o'clock, increases clockwise */
            if (ang < 0) ang += 2 * M_PI;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (ang < sweep) ? to->pix[i] : from->pix[i];
        }
    }
}

/* --------------------------------------------------------------- pixelate */
static void fx_pixelate(const buf_t *from, const buf_t *to, buf_t *out, double t,
                         const tparams_t *p, int r0, int r1) {
    int w = from->w;
    double peak = 1.0 - fabs(2 * t - 1); /* 0 at ends, 1 at t=0.5 */
    int block = 1 + (int)lround(peak * (p->pixelate_size - 1));
    if (block < 1) block = 1;
    for (int y = r0; y < r1; y++) {
        int by = y - (y % block);
        for (int x = 0; x < w; x++) {
            int bx = x - (x % block);
            size_t si = (size_t)by * w + bx;
            size_t di = (size_t)y * w + x;
            out->pix[di] = px_lerp(from->pix[si], to->pix[si], t);
        }
    }
}

/* -------------------------------------------------------------------- wave */
static void fx_wave(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    int w = from->w;
    double amp = p->wave_amp, len = p->wave_length > 1 ? p->wave_length : 1;
    for (int y = r0; y < r1; y++) {
        double boundary = t * (w + 2 * amp) - amp + amp * sin(2 * M_PI * y / len);
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            out->pix[i] = (x < boundary) ? to->pix[i] : from->pix[i];
        }
    }
}

/* -------------------------------------------------------------------- spin */
static void fx_spin(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double scale = t < 0.02 ? 0.02 : t;
    double angle = (1 - t) * 2 * M_PI;
    double ca = cos(-angle), sa = sin(-angle);
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double dx = (x - cx), dy = (y - cy);
            double rx = (dx * ca - dy * sa) / scale;
            double ry = (dx * sa + dy * ca) / scale;
            double sx = cx + rx, sy = cy + ry;
            size_t i = (size_t)y * w + x;
            if (sx >= 0 && sx < w - 1 && sy >= 0 && sy < h - 1)
                out->pix[i] = px_lerp(from->pix[i], buf_sample_bilinear(to, sx, sy), t);
            else
                out->pix[i] = from->pix[i];
        }
    }
}

/* ---------------------------------------------------------------- open/close */
static void fx_open(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w;
    int gap = (int)lround(t * w);
    int lo = (w - gap) / 2, hi = lo + gap;
    for (int y = r0; y < r1; y++)
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            out->pix[i] = (x >= lo && x < hi) ? to->pix[i] : from->pix[i];
        }
}
static void fx_close(const buf_t *from, const buf_t *to, buf_t *out, double t,
                      const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w;
    int covered = (int)lround(t * (w / 2.0));
    for (int y = r0; y < r1; y++)
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            int in_curtain = (x < covered) || (x >= w - covered);
            out->pix[i] = in_curtain ? to->pix[i] : from->pix[i];
        }
}

/* ---------------------------------------------------------------- zoom */
static void fx_zoom_in(const buf_t *from, const buf_t *to, buf_t *out, double t,
                        const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double scale = t < 0.02 ? 0.02 : t;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double sx = cx + (x - cx) / scale;
            double sy = cy + (y - cy) / scale;
            size_t i = (size_t)y * w + x;
            if (sx >= 0 && sx < w - 1 && sy >= 0 && sy < h - 1)
                out->pix[i] = buf_sample_bilinear(to, sx, sy);
            else
                out->pix[i] = from->pix[i];
        }
    }
}
static void fx_zoom_out(const buf_t *from, const buf_t *to, buf_t *out, double t,
                         const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double scale = (1 - t) < 0.02 ? 0.02 : (1 - t);
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double sx = cx + (x - cx) / scale;
            double sy = cy + (y - cy) / scale;
            size_t i = (size_t)y * w + x;
            if (sx >= 0 && sx < w - 1 && sy >= 0 && sy < h - 1)
                out->pix[i] = buf_sample_bilinear(from, sx, sy);
            else
                out->pix[i] = to->pix[i];
        }
    }
}

/* ------------------------------------------------------------------- dissolve */
static void fx_dissolve(const buf_t *from, const buf_t *to, buf_t *out, double t,
                         const tparams_t *p, int r0, int r1) {
    int w = from->w;
    for (int y = r0; y < r1; y++)
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            out->pix[i] = (hash01(x, y, p->seed) < t) ? to->pix[i] : from->pix[i];
        }
}

/* ------------------------------------------------------------------- checker */
static void fx_checker(const buf_t *from, const buf_t *to, buf_t *out, double t,
                        const tparams_t *p, int r0, int r1) {
    int w = from->w;
    int cs = p->checker_size > 1 ? p->checker_size : 1;
    for (int y = r0; y < r1; y++) {
        int cyi = y / cs;
        for (int x = 0; x < w; x++) {
            int cxi = x / cs;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (hash01(cxi, cyi, p->seed) < t) ? to->pix[i] : from->pix[i];
        }
    }
}

/* -------------------------------------------------------------------- blinds */
static void blinds_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                            const tparams_t *p, int r0, int r1, int horizontal) {
    int w = from->w, h = from->h;
    int n = p->blinds_count > 0 ? p->blinds_count : 1;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int idx = horizontal ? (y * n / h) : (x * n / w);
            double local = t * n - idx;
            if (local < 0) local = 0;
            if (local > 1) local = 1;
            size_t i = (size_t)y * w + x;
            out->pix[i] = px_lerp(from->pix[i], to->pix[i], local);
        }
    }
}
static void fx_blinds_h(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { blinds_generic(f, t2, o, t, p, r0, r1, 1); }
static void fx_blinds_v(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { blinds_generic(f, t2, o, t, p, r0, r1, 0); }

/* --------------------------------------------------------------------- none */
static void fx_none(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    (void)from; (void)p;
    int w = to->w;
    for (int y = r0; y < r1; y++)
        memcpy(&out->pix[(size_t)y * w], &to->pix[(size_t)y * w], (size_t)w * sizeof(uint32_t));
    (void)t;
}

/* ------------------------------------------------------------------- table */
static const transition_entry_t TABLE[] = {
    { "none",         fx_none,          "instant cut, no animation" },
    { "fade",         fx_fade,          "cross-fade" },
    { "wipe-left",    fx_wipe_left,     "hard-edge wipe, reveals left-to-right" },
    { "wipe-right",   fx_wipe_right,    "hard-edge wipe, reveals right-to-left" },
    { "wipe-up",      fx_wipe_down,     "hard-edge wipe, reveals top-to-bottom" },
    { "wipe-down",    fx_wipe_up,       "hard-edge wipe, reveals bottom-to-top" },
    { "slide-left",   fx_slide_left,    "new image slides in from the right" },
    { "slide-right",  fx_slide_right,   "new image slides in from the left" },
    { "slide-up",     fx_slide_up,      "new image slides in from the bottom" },
    { "slide-down",   fx_slide_down,    "new image slides in from the top" },
    { "push-left",    fx_push_left,     "old+new both slide left together" },
    { "push-right",   fx_push_right,    "old+new both slide right together" },
    { "push-up",      fx_push_up,       "old+new both slide up together" },
    { "push-down",    fx_push_down,     "old+new both slide down together" },
    { "oblique-left",  fx_oblique_left,  "diagonal wipe, top-right to bottom-left" },
    { "oblique-right", fx_oblique_right, "diagonal wipe, top-left to bottom-right" },
    { "emerge-left",  fx_emerge_left,   "new image emerges from the left edge" },
    { "emerge-right", fx_emerge_right,  "new image emerges from the right edge" },
    { "emerge-up",    fx_emerge_up,     "new image emerges from the top edge" },
    { "emerge-down",  fx_emerge_down,   "new image emerges from the bottom edge" },
    { "circle-out",   fx_circle_out,    "hard circle grows from center" },
    { "circle-in",    fx_circle_in,     "hard circle shrinks to center" },
    { "grow-center",  fx_grow_center,   "soft/feathered circle grows from center" },
    { "diamond",      fx_diamond,       "diamond grows from center" },
    { "clock",        fx_clock,         "radial clock-hand sweep" },
    { "pixelate",     fx_pixelate,      "blocky pixelation cross-fade" },
    { "wave",         fx_wave,          "sinusoidal wipe boundary" },
    { "spin",         fx_spin,          "new image spins and scales in" },
    { "open",         fx_open,          "curtain opens from center revealing new image" },
    { "close",        fx_close,         "curtains close in from the edges" },
    { "zoom-in",      fx_zoom_in,       "new image zooms in from center" },
    { "zoom-out",     fx_zoom_out,      "old image zooms out from center" },
    { "dissolve",     fx_dissolve,      "random per-pixel dissolve" },
    { "checker",      fx_checker,       "random checkerboard-cell reveal" },
    { "blinds-h",     fx_blinds_h,      "horizontal venetian blinds" },
    { "blinds-v",     fx_blinds_v,      "vertical venetian blinds" },
};
static const int TABLE_N = (int)(sizeof(TABLE) / sizeof(TABLE[0]));

const transition_entry_t *transitions_table(int *count) {
    if (count) *count = TABLE_N;
    return TABLE;
}

const transition_entry_t *transition_find(const char *name) {
    if (!name) return NULL;
    for (int i = 0; i < TABLE_N; i++)
        if (strcasecmp(TABLE[i].name, name) == 0) return &TABLE[i];
    return NULL;
}

const transition_entry_t *transition_pick_random(const char *csv_list) {
    if (csv_list && *csv_list) {
        /* count entries */
        int n = 1;
        for (const char *c = csv_list; *c; c++) if (*c == ',') n++;
        int pick = xrng_int(0, n - 1);
        char *copy = strdup(csv_list);
        char *tok = strtok(copy, ",");
        const transition_entry_t *found = NULL;
        for (int i = 0; tok; i++, tok = strtok(NULL, ",")) {
            while (*tok == ' ') tok++;
            if (i == pick) { found = transition_find(tok); break; }
        }
        free(copy);
        if (found) return found;
    }
    return &TABLE[1 + xrng_int(0, TABLE_N - 2)]; /* skip "none" at index 0 */
}
