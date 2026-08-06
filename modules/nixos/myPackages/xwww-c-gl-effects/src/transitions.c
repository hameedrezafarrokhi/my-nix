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
    p.origin_x_pct = 50;
    p.origin_y_pct = 50;
    p.oblique_angle = 45;
    p.curl_pct = 5;
    p.shard_size = 64;
    p.burn_patches = 10;
    p.burn_jaggedness = 0.5;
    p.pivot_pct = 50;
    p.cube_zoom = 0.3;
    p.cube_spin_speed = 1.5;
    p.axisspin_vertical = 0;
    p.axisspin_turns = 6;
    p.ripple_amp = 18;
    p.ripple_freq = 0.15;
    p.ripple_droplets = 0;
    p.flicker_min_brightness = 0.12;
    p.flicker_count = 8;
    p.logo = NULL;
    p.logo_static_frac = 0.15;
    p.logo_fadein_frac = 0.15;
    p.logo_spin_speed = 3.0;
    p.logo_zoom_speed = 1.0;
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

/* Resolve an effect's configured origin point to pixel coords, and the
 * farthest-corner distance from it (so a growing circle/diamond/etc.
 * always fully covers the canvas by t=1 no matter where the origin is). */
static void origin_and_maxr(const tparams_t *p, int w, int h, double *cx, double *cy, double *maxr) {
    *cx = w * (p->origin_x_pct / 100.0);
    *cy = h * (p->origin_y_pct / 100.0);
    double d00 = hypot(*cx - 0, *cy - 0);
    double d10 = hypot(*cx - w, *cy - 0);
    double d01 = hypot(*cx - 0, *cy - h);
    double d11 = hypot(*cx - w, *cy - h);
    double m = d00;
    if (d10 > m) m = d10;
    if (d01 > m) m = d01;
    if (d11 > m) m = d11;
    *maxr = m;
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
                             const tparams_t *p, int r0, int r1, int mirror) {
    int w = from->w, h = from->h;
    double theta = p->oblique_angle * M_PI / 180.0;
    double dirx = cos(theta), diry = sin(theta);
    if (mirror) dirx = -dirx;
    /* project the four corners onto the sweep direction to find the
     * threshold's start/end regardless of angle or canvas aspect ratio */
    double c00 = 0 * dirx + 0 * diry;
    double c10 = w * dirx + 0 * diry;
    double c01 = 0 * dirx + h * diry;
    double c11 = w * dirx + h * diry;
    double dmin = c00, dmax = c00;
    double cs[3] = { c10, c01, c11 };
    for (int i = 0; i < 3; i++) { if (cs[i] < dmin) dmin = cs[i]; if (cs[i] > dmax) dmax = cs[i]; }
    double threshold = dmin + t * (dmax - dmin);
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double d = x * dirx + y * diry;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (d < threshold) ? to->pix[i] : from->pix[i];
        }
    }
}
static void fx_oblique_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { oblique_generic(f, t2, o, t, p, r0, r1, 0); }
static void fx_oblique_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { oblique_generic(f, t2, o, t, p, r0, r1, 1); }

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
    int w = from->w;
    double cx, cy, maxr;
    origin_and_maxr(p, w, from->h, &cx, &cy, &maxr);
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
    int w = from->w;
    double cx, cy, maxr;
    origin_and_maxr(p, w, from->h, &cx, &cy, &maxr);
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
    int w = from->w;
    double cx, cy, maxr;
    origin_and_maxr(p, w, from->h, &cx, &cy, &maxr);
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
    int w = from->w;
    double cx, cy, maxr;
    origin_and_maxr(p, w, from->h, &cx, &cy, &maxr);
    double maxd = fabs(cx) + fabs(cy);
    double d2 = fabs(w - cx) + fabs(cy);       if (d2 > maxd) maxd = d2;
    double d3 = fabs(cx) + fabs(from->h - cy); if (d3 > maxd) maxd = d3;
    double d4 = fabs(w - cx) + fabs(from->h - cy); if (d4 > maxd) maxd = d4;
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
    int w = from->w;
    double cx, cy, maxr;
    origin_and_maxr(p, w, from->h, &cx, &cy, &maxr);
    (void)maxr;
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

/* --------------------------------------------------------------- stripes
 * Screen divided into N parallel stripes; each stripe does its own slide
 * transition, staggered so they don't all move at once -- a cascading
 * "waterfall" of bars. blinds_count controls the stripe count. */
static void stripes_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                             const tparams_t *p, int r0, int r1, int vertical_stripes, int reverse_order) {
    int w = from->w, h = from->h;
    int n = p->blinds_count > 0 ? p->blinds_count : 1;
    double stagger_span = 0.65; /* fraction of total duration spread across stripe start times */
    double window = 1.0 - stagger_span;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int idx = vertical_stripes ? (x * n / w) : (y * n / h);
            if (reverse_order) idx = n - 1 - idx;
            double delay = (n > 1) ? (double)idx / (n - 1) * stagger_span : 0;
            double local_t = (t - delay) / window;
            if (local_t < 0) local_t = 0;
            if (local_t > 1) local_t = 1;

            size_t i = (size_t)y * w + x;
            if (vertical_stripes) {
                /* stripe is a column; it slides in vertically from the top */
                double off = (1 - local_t) * h;
                int sy = (int)(y - off);
                out->pix[i] = (sy >= 0 && sy < h) ? to->pix[(size_t)sy * w + x] : from->pix[i];
            } else {
                /* stripe is a row; it slides in horizontally from the left */
                double off = (1 - local_t) * w;
                int sx = (int)(x - off);
                out->pix[i] = (sx >= 0 && sx < w) ? to->pix[(size_t)y * w + sx] : from->pix[i];
            }
        }
    }
}
static void fx_stripes_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { stripes_generic(f, t2, o, t, p, r0, r1, 1, 0); }
static void fx_stripes_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { stripes_generic(f, t2, o, t, p, r0, r1, 1, 1); }
static void fx_stripes_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { stripes_generic(f, t2, o, t, p, r0, r1, 0, 0); }
static void fx_stripes_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { stripes_generic(f, t2, o, t, p, r0, r1, 0, 1); }

/* diagonal cascade variant: same idea, but the bands run at oblique_angle
 * instead of straight vertical/horizontal, and slide perpendicular to
 * that angle instead of top-down/left-right. */
static void stripes_oblique_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                                     const tparams_t *p, int r0, int r1, int mirror) {
    int w = from->w, h = from->h;
    double theta = p->oblique_angle * M_PI / 180.0;
    double dirx = cos(theta), diry = sin(theta);
    if (mirror) dirx = -dirx;
    double c10 = w * dirx, c01 = h * diry, c11 = w * dirx + h * diry;
    double dmin = 0, dmax = 0;
    double cs[3] = { c10, c01, c11 };
    for (int i = 0; i < 3; i++) { if (cs[i] < dmin) dmin = cs[i]; if (cs[i] > dmax) dmax = cs[i]; }
    double range = (dmax - dmin) > 1 ? (dmax - dmin) : 1;
    int n = p->blinds_count > 0 ? p->blinds_count : 1;
    double stagger_span = 0.65, window = 1.0 - stagger_span;
    double perp_x = -diry, perp_y = dirx;
    double max_off = fabs(perp_x) * w + fabs(perp_y) * h;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double d = x * dirx + y * diry;
            double frac = (d - dmin) / range;
            int idx = (int)(frac * n);
            if (idx >= n) idx = n - 1;
            if (idx < 0) idx = 0;
            double delay = (n > 1) ? (double)idx / (n - 1) * stagger_span : 0;
            double local_t = (t - delay) / window;
            if (local_t < 0) local_t = 0;
            if (local_t > 1) local_t = 1;

            double off = (1 - local_t) * max_off;
            int sx = (int)(x - perp_x * off);
            int sy = (int)(y - perp_y * off);
            size_t i = (size_t)y * w + x;
            out->pix[i] = (sx >= 0 && sx < w && sy >= 0 && sy < h) ? to->pix[(size_t)sy * w + sx] : from->pix[i];
        }
    }
}
static void fx_stripes_oblique_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { stripes_oblique_generic(f, t2, o, t, p, r0, r1, 0); }
static void fx_stripes_oblique_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { stripes_oblique_generic(f, t2, o, t, p, r0, r1, 1); }

/* ---------------------------------------------------------------- panes
 * This is what was originally meant by "parallel lines": the screen is
 * divided into N parallel bands (blinds_count), and EVERY band reveals
 * "to" via its own wipe growing from one of its own edges toward the
 * next line -- all bands moving together, not staggered like stripes-*.
 * Think many independent mini blinds opening in sync, rather than a
 * cascade. */
static void panes_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                           const tparams_t *p, int r0, int r1, int vertical_panes, int reverse) {
    int w = from->w, h = from->h;
    int n = p->blinds_count > 0 ? p->blinds_count : 1;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            int reveal;
            if (vertical_panes) {
                int idx = x * n / w;
                int x0 = idx * w / n, x1 = (idx + 1) * w / n;
                if (idx == n - 1) x1 = w;
                double local_w = x1 - x0;
                double boundary = reverse ? (x1 - t * local_w) : (x0 + t * local_w);
                reveal = reverse ? (x >= boundary) : (x < boundary);
            } else {
                int idx = y * n / h;
                int y0 = idx * h / n, y1 = (idx + 1) * h / n;
                if (idx == n - 1) y1 = h;
                double local_h = y1 - y0;
                double boundary = reverse ? (y1 - t * local_h) : (y0 + t * local_h);
                reveal = reverse ? (y >= boundary) : (y < boundary);
            }
            out->pix[i] = reveal ? to->pix[i] : from->pix[i];
        }
    }
}
static void fx_panes_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { panes_generic(f, t2, o, t, p, r0, r1, 1, 0); }
static void fx_panes_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { panes_generic(f, t2, o, t, p, r0, r1, 1, 1); }
static void fx_panes_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { panes_generic(f, t2, o, t, p, r0, r1, 0, 0); }
static void fx_panes_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { panes_generic(f, t2, o, t, p, r0, r1, 0, 1); }

/* -------------------------------------------------------------- fire-ring
 * This is the effect that used to be called "burn" -- a clean radial
 * fire front (respects origin_x_pct/origin_y_pct): unburned "from" ->
 * bright fire edge -> charred ring -> "to". Kept because it looks good,
 * just renamed once it was clear "burn" itself needed to mean something
 * more irregular -- see fx_burn below for that. */
static void fx_fire_ring(const buf_t *from, const buf_t *to, buf_t *out, double t,
                          const tparams_t *p, int r0, int r1) {
    int w = from->w;
    double cx, cy, maxr;
    origin_and_maxr(p, w, from->h, &cx, &cy, &maxr);
    double radius = t * maxr;
    double band = maxr * 0.06 + 2;
    const uint32_t FIRE = 0xFFFF7A00u;
    const uint32_t CHAR = 0xFF140800u;
    for (int y = r0; y < r1; y++) {
        double dy = y - cy;
        for (int x = 0; x < w; x++) {
            double dx = x - cx;
            double d = sqrt(dx * dx + dy * dy);
            size_t i = (size_t)y * w + x;
            if (d > radius + band) {
                out->pix[i] = from->pix[i];
            } else if (d > radius) {
                double u = (d - radius) / band;
                out->pix[i] = px_lerp(FIRE, from->pix[i], u);
            } else if (d > radius - band) {
                double u = (radius - d) / band;
                out->pix[i] = px_lerp(FIRE, CHAR, u);
            } else {
                double u = smoothstep(0, band * 0.6, (radius - band) - d);
                out->pix[i] = px_lerp(CHAR, to->pix[i], u);
            }
        }
    }
}

/* ------------------------------------------------------------------ burn
 * The real thing this time: burn_patches independent ignition points
 * (random position, random start delay, each own irregular growth rate)
 * grow into jagged blobs -- not circles: each blob's radius is perturbed
 * by a couple of sine harmonics at a per-seed random phase/frequency, so
 * the boundary looks torn rather than round -- and the blobs merge into
 * each other as they grow (this is a union: a pixel is "burned" as soon
 * as ANY patch reaches it). Right at an active boundary, sparse bright
 * pixels flare as embers, drifting upward with t. */
static double jagged_radius(double base_r, double angle, int seed_id, double seed, double jaggedness) {
    double ph1 = hash01(seed_id, 101, seed) * 2 * M_PI;
    double ph2 = hash01(seed_id, 202, seed) * 2 * M_PI;
    double f1 = 3 + hash01(seed_id, 303, seed) * 3;   /* 3-6 */
    double f2 = 7 + hash01(seed_id, 404, seed) * 5;   /* 7-12 */
    double wobble = 0.35 * sin(angle * f1 + ph1) + 0.22 * sin(angle * f2 + ph2);
    double r = base_r * (1.0 + jaggedness * wobble);
    return r < 0 ? 0 : r;
}

static void fx_burn(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    int K = p->burn_patches > 1 ? p->burn_patches : 1;
    if (K > 24) K = 24; /* keep the per-pixel seed loop bounded */
    double maxext = sqrt((double)w * w + (double)h * h);
    double jag = p->burn_jaggedness < 0 ? 0 : (p->burn_jaggedness > 1 ? 1 : p->burn_jaggedness);
    double band = maxext * 0.025 + 3;

    double sx[24], sy[24], stagger[24];
    for (int i = 0; i < K; i++) {
        /* first seed defaults to the configured origin so users can still
         * anchor the burn's earliest patch somewhere specific */
        if (i == 0) {
            sx[i] = w * (p->origin_x_pct / 100.0);
            sy[i] = h * (p->origin_y_pct / 100.0);
        } else {
            sx[i] = hash01(i, 11, p->seed) * w;
            sy[i] = hash01(i, 22, p->seed) * h;
        }
        stagger[i] = hash01(i, 33, p->seed) * 0.45;
    }

    const uint32_t FIRE = 0xFFFF7A00u;
    const uint32_t CHAR = 0xFF160800u;
    const uint32_t EMBER = 0xFFFFE0A0u;

    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double best = -1e18;
            for (int i = 0; i < K; i++) {
                double dx = x - sx[i], dy = y - sy[i];
                double dist = sqrt(dx * dx + dy * dy);
                double local_t = (t - stagger[i]) / (1.0 - stagger[i]);
                if (local_t < 0) local_t = 0;
                if (local_t > 1) local_t = 1;
                double radius = local_t * maxext * 0.75;
                double angle = atan2(dy, dx);
                double jr = jagged_radius(radius, angle, i, p->seed, jag);
                double depth = jr - dist;
                if (depth > best) best = depth;
            }

            size_t idx = (size_t)y * w + x;
            uint32_t col;
            if (best > band) {
                col = to->pix[idx];
            } else if (best > 0) {
                col = px_lerp(CHAR, to->pix[idx], best / band);
            } else if (best > -band) {
                col = px_lerp(FIRE, from->pix[idx], (-best) / band);
            } else {
                col = from->pix[idx];
            }

            if (best > -band * 1.4 && best < band * 2.2) {
                double drift_y = y + t * 45.0;
                double spark = hash01((int)x, (int)drift_y, p->seed + 7.13);
                if (spark > 0.986) col = EMBER;
            }
            out->pix[idx] = col;
        }
    }
}


/* ------------------------------------------------------- door (swing/page-turn)
 * A "door_img" panel of width s*axis_len (0..1 of full length), anchored
 * at one edge, showing a horizontally- or vertically-compressed sample of
 * door_img; the rest of the canvas shows bg_img. curl_px>0 adds a
 * highlight/shadow band at the door's free (moving) edge to suggest a
 * curling page rather than a flat swinging panel -- swing-* leaves this
 * at 0, page-turn-* turns it on. Shading also dims the door panel as it
 * narrows, to suggest it's turning away from the light. */
/* --------------------------------------------- door (swing/page-turn/book)
 * A panel of `door_img` content, hinged at a configurable pivot_x/pivot_y
 * and swinging open/closed on one side of it; on the SAME side of the
 * pivot but not currently covered by the panel, the other image shows
 * (already revealed / not yet reached); on the OPPOSITE side of the
 * pivot, `crossfade_opposite` decides whether that region just does a
 * plain fade (used by half-swing and book-style page-turn, where only
 * one side of the hinge physically "moves") or also shows the other
 * image outright. curl_px>0 adds a highlight/shadow band at the panel's
 * free (moving) edge to read as a curling page rather than a flat door;
 * shading also dims the panel as it narrows, suggesting it's turning
 * away from the light. */
static void door_horiz_pivot(const buf_t *from, const buf_t *to, buf_t *out, double t,
                              double pivot_x, int door_is_to, int dir, double curl_px,
                              int crossfade_opposite, int r0, int r1) {
    int w = out->w;
    double s = door_is_to ? t : (1 - t);
    const buf_t *door_img = door_is_to ? to : from;
    double reach = dir > 0 ? (w - pivot_x) : pivot_x;
    if (reach < 1) reach = 1;
    double door_len = s * reach;
    double door_lo = dir > 0 ? pivot_x : (pivot_x - door_len);
    double door_hi = dir > 0 ? (pivot_x + door_len) : pivot_x;
    double free_edge = dir > 0 ? door_hi : door_lo;
    double shade_base = 0.35 + 0.65 * s;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            int side = (x >= pivot_x) ? 1 : -1;
            if (side != dir) {
                out->pix[i] = crossfade_opposite ? px_lerp(from->pix[i], to->pix[i], t)
                                                  : (door_is_to ? from->pix[i] : to->pix[i]);
                continue;
            }
            if (door_len >= 0.5 && x >= door_lo && x < door_hi) {
                double src_x = dir > 0 ? (pivot_x + (x - pivot_x) / s) : (pivot_x - (pivot_x - x) / s);
                double shade = shade_base;
                if (curl_px > 0) {
                    double dist = fabs(x - free_edge);
                    if (dist < curl_px) shade *= 1.0 + (1 - dist / curl_px) * 0.6;
                }
                if (shade > 1.4) shade = 1.4;
                uint32_t c = buf_sample_bilinear(door_img, src_x, y);
                uint8_t rr = (uint8_t)fmin(255, px_r(c) * shade);
                uint8_t gg = (uint8_t)fmin(255, px_g(c) * shade);
                uint8_t bb = (uint8_t)fmin(255, px_b(c) * shade);
                out->pix[i] = px_pack(px_a(c), rr, gg, bb);
            } else {
                uint32_t c = door_is_to ? from->pix[i] : to->pix[i];
                if (curl_px > 0) {
                    double dist = fabs(x - free_edge);
                    if (dist < curl_px * 0.6) {
                        double dk = 0.55 + 0.45 * (dist / (curl_px * 0.6));
                        c = px_pack(px_a(c), (uint8_t)(px_r(c) * dk), (uint8_t)(px_g(c) * dk), (uint8_t)(px_b(c) * dk));
                    }
                }
                out->pix[i] = c;
            }
        }
    }
}
static void door_vert_pivot(const buf_t *from, const buf_t *to, buf_t *out, double t,
                             double pivot_y, int door_is_to, int dir, double curl_px,
                             int crossfade_opposite, int r0, int r1) {
    int w = out->w, h = out->h;
    double s = door_is_to ? t : (1 - t);
    const buf_t *door_img = door_is_to ? to : from;
    double reach = dir > 0 ? (h - pivot_y) : pivot_y;
    if (reach < 1) reach = 1;
    double door_len = s * reach;
    double door_lo = dir > 0 ? pivot_y : (pivot_y - door_len);
    double door_hi = dir > 0 ? (pivot_y + door_len) : pivot_y;
    double free_edge = dir > 0 ? door_hi : door_lo;
    double shade_base = 0.35 + 0.65 * s;
    for (int y = r0; y < r1; y++) {
        int side = (y >= pivot_y) ? 1 : -1;
        int in_door = (side == dir) && door_len >= 0.5 && y >= door_lo && y < door_hi;
        double src_y = in_door ? (dir > 0 ? (pivot_y + (y - pivot_y) / s) : (pivot_y - (pivot_y - y) / s)) : 0;
        double shade = shade_base;
        if (in_door && curl_px > 0) {
            double dist = fabs(y - free_edge);
            if (dist < curl_px) shade *= 1.0 + (1 - dist / curl_px) * 0.6;
            if (shade > 1.4) shade = 1.4;
        }
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            if (side != dir) {
                out->pix[i] = crossfade_opposite ? px_lerp(from->pix[i], to->pix[i], t)
                                                  : (door_is_to ? from->pix[i] : to->pix[i]);
            } else if (in_door) {
                uint32_t c = buf_sample_bilinear(door_img, x, src_y);
                uint8_t rr = (uint8_t)fmin(255, px_r(c) * shade);
                uint8_t gg = (uint8_t)fmin(255, px_g(c) * shade);
                uint8_t bb = (uint8_t)fmin(255, px_b(c) * shade);
                out->pix[i] = px_pack(px_a(c), rr, gg, bb);
            } else {
                uint32_t c = door_is_to ? from->pix[i] : to->pix[i];
                if (curl_px > 0) {
                    double dist = fabs(y - free_edge);
                    if (dist < curl_px * 0.6) {
                        double dk = 0.55 + 0.45 * (dist / (curl_px * 0.6));
                        c = px_pack(px_a(c), (uint8_t)(px_r(c) * dk), (uint8_t)(px_g(c) * dk), (uint8_t)(px_b(c) * dk));
                    }
                }
                out->pix[i] = c;
            }
        }
    }
}

/* full-swing: hinge at the screen edge, the whole width swings -- this is
 * the original "swing" effect, just renamed for clarity now that
 * half-swing exists alongside it. */
static void fx_full_swing_forward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    (void)p; door_horiz_pivot(f, t2, o, t, o->w, 0, -1, 0, 0, r0, r1);
}
static void fx_full_swing_backward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    (void)p; door_horiz_pivot(f, t2, o, t, 0, 1, 1, 0, 0, r0, r1);
}

/* half-swing: same door motion, but hinged at a configurable interior
 * point (pivot_pct) rather than the screen edge -- only the side of the
 * pivot in the swing's direction actually swings; the other side just
 * crossfades, like it's a separate, stationary wall panel. */
static void fx_half_swing_forward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    double pivot = o->w * (p->pivot_pct / 100.0);
    door_horiz_pivot(f, t2, o, t, pivot, 0, 1, 0, 1, r0, r1);
}
static void fx_half_swing_backward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    double pivot = o->w * (p->pivot_pct / 100.0);
    door_horiz_pivot(f, t2, o, t, pivot, 1, -1, 0, 1, r0, r1);
}

/* page-turn (book-style): hinge fixed at the center spine, like an open
 * book -- one half of the screen curls over the spine like a real page,
 * the other half (the "other page") just crossfades since it isn't the
 * page being turned. */
static void fx_page_turn_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    door_horiz_pivot(f, t2, o, t, o->w / 2.0, 0, -1, o->w * (p->curl_pct / 100.0), 1, r0, r1);
}
static void fx_page_turn_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    door_horiz_pivot(f, t2, o, t, o->w / 2.0, 0, 1, o->w * (p->curl_pct / 100.0), 1, r0, r1);
}
static void fx_page_turn_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    door_vert_pivot(f, t2, o, t, o->h / 2.0, 0, -1, o->h * (p->curl_pct / 100.0), 1, r0, r1);
}
static void fx_page_turn_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) {
    door_vert_pivot(f, t2, o, t, o->h / 2.0, 0, 1, o->h * (p->curl_pct / 100.0), 1, r0, r1);
}


/* --------------------------------------------------------------- shatter
 * `from` breaks into IRREGULAR polygon pieces -- a jittered Voronoi
 * diagram (each grid cell's seed point is randomly offset; the nearest-
 * seed regions are naturally irregular convex polygons, the same cheap
 * trick shader people use for cracked-glass/cell noise). Each piece gets
 * its own random fall direction/speed plus gravity, and a thin bright
 * crack line lights up right at piece boundaries early in the break,
 * fading as the pieces separate and fall away to reveal `to`. Pieces
 * translate but don't rotate -- true per-shard rotation would need
 * actual polygon geometry, not just a per-pixel displacement trick. */
static void fx_shatter(const buf_t *from, const buf_t *to, buf_t *out, double t,
                        const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    int cs = p->shard_size > 4 ? p->shard_size : 64;
    double alpha_from = 1.0 - smoothstep(0.35, 1.0, t);
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            if (alpha_from < 0.01) { out->pix[i] = to->pix[i]; continue; }

            int gx = x / cs, gy = y / cs;
            double best = 1e18, best2 = 1e18;
            int bci = 0, bcj = 0;
            for (int dcy = -1; dcy <= 1; dcy++) {
                for (int dcx = -1; dcx <= 1; dcx++) {
                    int ci = gx + dcx, cj = gy + dcy;
                    double jx = hash01(ci, cj, p->seed) * cs;
                    double jy = hash01(ci, cj, p->seed + 0.5) * cs;
                    double seedx = ci * cs + jx, seedy = cj * cs + jy;
                    double dxp = x - seedx, dyp = y - seedy;
                    double d = dxp * dxp + dyp * dyp;
                    if (d < best) { best2 = best; best = d; bci = ci; bcj = cj; }
                    else if (d < best2) { best2 = d; }
                }
            }
            double edge = sqrt(best2) - sqrt(best); /* small near a cell boundary */

            double a = hash01(bci, bcj, p->seed) * 2 * M_PI;
            double sp = 0.5 + hash01(bci, bcj, p->seed + 0.371) * 1.5;
            double disp = t * t * cs * 6 * sp;
            double dx = cos(a) * disp;
            double dy = sin(a) * disp + t * t * cs * 4; /* gravity */
            double sx = x - dx, sy = y - dy;

            uint32_t result;
            if (sx >= 0 && sx < w - 1 && sy >= 0 && sy < h - 1) {
                uint32_t fp = buf_sample_bilinear(from, sx, sy);
                result = px_lerp(to->pix[i], fp, alpha_from);
                if (edge < 1.5 && t < 0.6) {
                    double crack_a = (1.0 - edge / 1.5) * (1.0 - t / 0.6) * alpha_from * 0.5;
                    result = px_lerp(result, 0xFFFFFFFFu, crack_a);
                }
            } else {
                result = to->pix[i];
            }
            out->pix[i] = result;
        }
    }
}

/* ---------------------------------------------------------------- matrix
 * This is what used to be called "melt": staggered per-column reveal with
 * a sinusoidal wipe boundary. Renamed once "melt" itself needed to mean
 * an actual goo drip -- see fx_melt below. */
static void fx_matrix(const buf_t *from, const buf_t *to, buf_t *out, double t,
                       const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    double window = 0.4;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double stagger = hash01(x, 7, p->seed);
            double local_t = (t - stagger * (1 - window)) / window;
            if (local_t < 0) local_t = 0;
            if (local_t > 1) local_t = 1;
            double wobble = 4.0 * sin(x * 0.08 + local_t * 6.0) * local_t;
            double boundary = h * local_t + wobble;
            size_t i = (size_t)y * w + x;
            out->pix[i] = (y < boundary) ? to->pix[i] : from->pix[i];
        }
    }
}

/* ------------------------------------------------------------------ melt
 * The real thing this time: colors smear/morph across a soft (not hard)
 * boundary, and the old image's content visibly sags downward like goo
 * before it's gone -- sampled from higher up than the output row, with
 * the sag amount growing through each column's own local timing, plus a
 * slow horizontal wobble so it reads as flowing rather than just sliding. */
static void fx_melt(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    int block = 10; /* group columns into blobs, not single-pixel columns */
    double window = 0.55;
    double band = fmax(20.0, h * 0.06);
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int bx = x / block;
            double stagger = hash01(bx, 3, p->seed);
            double local_t = (t - stagger * (1 - window)) / window;
            if (local_t < 0) local_t = 0;
            if (local_t > 1) local_t = 1;

            double wobble = 6.0 * sin(x * 0.05 + local_t * 5.0) * local_t;
            double boundary = h * local_t + wobble;
            double mix = smoothstep(boundary - band, boundary + band, y);

            double drip = 24.0 * local_t * local_t;
            double xwob = 3.0 * sin(y * 0.05 + t * 3.0);
            uint32_t sagged_from = buf_sample_bilinear(from, x + xwob, y - drip);

            size_t i = (size_t)y * w + x;
            out->pix[i] = px_lerp(to->pix[i], sagged_from, mix);
        }
    }
}

/* ------------------------------------------------------ roll-away / carpet
 * A real cylindrical roll: within a band of radius R straddling the wipe
 * boundary, the transitioning image is shaded and lightly compressed
 * following a sine falloff (bright/full at the band's center, darkening
 * and shifting toward the edges) to read as a curved surface rather than
 * a flat cut with a highlight line riding on it. Beyond the band on
 * either side, the flat unaffected image shows normally. carpet-* is the
 * same mechanic with `to` as the material on the roll instead of `from`. */
static void roll_generic(const buf_t *from, const buf_t *to, buf_t *out, double t,
                          const tparams_t *p, int r0, int r1, int axis, int dir, int style) {
    int w = from->w, h = from->h;
    int L = axis ? h : w;
    double R = fmax(15.0, L * (p->curl_pct / 100.0) * 3.0);
    double boundary = t * L;
    double bpos = (dir > 0) ? boundary : (L - boundary);
    const buf_t *roll_img = (style == 0) ? from : to;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            int a = axis ? y : x;
            double s = (dir > 0) ? (a - bpos) : (bpos - a);
            size_t i = (size_t)y * w + x;
            if (s > R) {
                out->pix[i] = from->pix[i];
            } else if (s < -R) {
                out->pix[i] = to->pix[i];
            } else {
                double u = (s + R) / (2 * R);
                double angle = u * M_PI;
                double brightness = sin(angle);
                double shade = 0.35 + 0.65 * brightness;
                double compress = (1.0 - brightness) * 10.0 * (s >= 0 ? 1.0 : -1.0);
                double sample_a = a - compress;
                double sx = axis ? x : sample_a;
                double sy = axis ? sample_a : y;
                uint32_t c = buf_sample_bilinear(roll_img, sx, sy);
                uint8_t rr = (uint8_t)fmin(255, px_r(c) * shade);
                uint8_t gg = (uint8_t)fmin(255, px_g(c) * shade);
                uint8_t bb = (uint8_t)fmin(255, px_b(c) * shade);
                out->pix[i] = px_pack(px_a(c), rr, gg, bb);
            }
        }
    }
}
static void fx_roll_away_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { roll_generic(f, t2, o, t, p, r0, r1, 1, -1, 0); }
static void fx_roll_away_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { roll_generic(f, t2, o, t, p, r0, r1, 1, 1, 0); }
static void fx_roll_away_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { roll_generic(f, t2, o, t, p, r0, r1, 0, -1, 0); }
static void fx_roll_away_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { roll_generic(f, t2, o, t, p, r0, r1, 0, 1, 0); }
static void fx_carpet_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)    { roll_generic(f, t2, o, t, p, r0, r1, 1, -1, 1); }
static void fx_carpet_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { roll_generic(f, t2, o, t, p, r0, r1, 1, 1, 1); }
static void fx_carpet_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1)  { roll_generic(f, t2, o, t, p, r0, r1, 0, -1, 1); }
static void fx_carpet_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p, int r0, int r1) { roll_generic(f, t2, o, t, p, r0, r1, 0, 1, 1); }

/* --------------------------------------------------------------- bubbles
 * Many soft-edged circles ("droplets") at random locations, random start
 * delays, and random expansion rates, each growing and merging with its
 * neighbors until the whole screen is covered. Shares its seed-generation
 * shape with fx_burn (reuses burn_patches as the bubble count) but with a
 * smooth soap-bubble edge instead of jagged fire. */
static void fx_bubbles(const buf_t *from, const buf_t *to, buf_t *out, double t,
                        const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    int K = p->burn_patches > 1 ? p->burn_patches : 1;
    if (K > 24) K = 24;
    double maxext = sqrt((double)w * w + (double)h * h);
    double band = maxext * 0.02 + 3;

    double sx[24], sy[24], stagger[24], rate[24];
    for (int i = 0; i < K; i++) {
        if (i == 0) {
            sx[i] = w * (p->origin_x_pct / 100.0);
            sy[i] = h * (p->origin_y_pct / 100.0);
        } else {
            sx[i] = hash01(i, 61, p->seed) * w;
            sy[i] = hash01(i, 62, p->seed) * h;
        }
        stagger[i] = hash01(i, 63, p->seed) * 0.5;
        rate[i] = 0.6 + hash01(i, 64, p->seed) * 0.8;
    }

    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double best = -1e18;
            for (int i = 0; i < K; i++) {
                double dx = x - sx[i], dy = y - sy[i];
                double dist = sqrt(dx * dx + dy * dy);
                double local_t = (t - stagger[i]) / (1.0 - stagger[i]);
                if (local_t < 0) local_t = 0;
                if (local_t > 1) local_t = 1;
                double radius = local_t * maxext * 0.75 * rate[i];
                double depth = radius - dist;
                if (depth > best) best = depth;
            }
            size_t i2 = (size_t)y * w + x;
            double a = smoothstep(-band, band, best);
            out->pix[i2] = px_lerp(from->pix[i2], to->pix[i2], a);
        }
    }
}

/* -------------------------------------------------------------- ripple
 * A radial reveal (from the configured origin, plus ripple_droplets
 * extra random ones) with a real sinusoidal displacement riding along
 * each expanding wavefront -- pixels near an active front get pushed
 * radially and sampled from BOTH images at that displaced position,
 * which is what actually creates the "blurring together" look; the
 * displacement dies out once a front has passed, leaving a clean "to". */
static void fx_ripple(const buf_t *from, const buf_t *to, buf_t *out, double t,
                       const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    int extra = p->ripple_droplets;
    if (extra < 0) extra = 0;
    if (extra > 4) extra = 4;
    int K = 1 + extra;
    double maxext = sqrt((double)w * w + (double)h * h);

    double sx[5], sy[5], stagger[5];
    sx[0] = w * (p->origin_x_pct / 100.0);
    sy[0] = h * (p->origin_y_pct / 100.0);
    stagger[0] = 0;
    for (int i = 1; i < K; i++) {
        sx[i] = hash01(i, 71, p->seed) * w;
        sy[i] = hash01(i, 72, p->seed) * h;
        stagger[i] = hash01(i, 73, p->seed) * 0.3;
    }

    double amp = p->ripple_amp, freq = p->ripple_freq;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double best = -1e18, total_disp = 0;
            for (int i = 0; i < K; i++) {
                double dx = x - sx[i], dy = y - sy[i];
                double dist = sqrt(dx * dx + dy * dy);
                double local_t = (t - stagger[i]) / (1.0 - stagger[i]);
                if (local_t < 0) local_t = 0;
                if (local_t > 1) local_t = 1;
                double front_r = local_t * maxext * 1.05;
                double depth = front_r - dist;
                if (depth > best) best = depth;
                double dist_to_front = fabs(dist - front_r);
                double envelope = exp(-(dist_to_front * dist_to_front) / (2 * 30.0 * 30.0));
                total_disp += sin(dist * freq - local_t * 20.0) * amp * envelope;
            }
            double blend = smoothstep(-40, 40, best);

            double ddx = x - sx[0], ddy = y - sy[0];
            double dd = sqrt(ddx * ddx + ddy * ddy);
            if (dd < 1) dd = 1;
            double nx = ddx / dd, ny = ddy / dd;
            double samp_x = x + nx * total_disp, samp_y = y + ny * total_disp;

            uint32_t fc = buf_sample_bilinear(from, samp_x, samp_y);
            uint32_t tc = buf_sample_bilinear(to, samp_x, samp_y);
            out->pix[(size_t)y * w + x] = px_lerp(fc, tc, blend);
        }
    }
}

/* -------------------------------------------------------------- flicker
 * A dying-bulb flicker: brightness follows a small number of random
 * keyframes, smoothly (never linearly-snapped) interpolated between them
 * -- deliberately eased rather than hard-strobing, and floored above 0 in
 * the middle keyframes, to stay well clear of anything seizure-inducing.
 * First half dims "from" down to black; second half brings "to" back up. */
static void fx_flicker(const buf_t *from, const buf_t *to, buf_t *out, double t,
                        const tparams_t *p, int r0, int r1) {
    int w = from->w;
    int N = p->flicker_count >= 2 ? p->flicker_count : 2;
    double minb = p->flicker_min_brightness;
    if (minb < 0) minb = 0;
    if (minb > 0.9) minb = 0.9;

    int using_to = (t >= 0.5);
    double half_t = using_to ? (t - 0.5) / 0.5 : t / 0.5;
    double salt = using_to ? 500.0 : 0.0;

    double seg = half_t * (N - 1);
    int k0 = (int)seg;
    if (k0 > N - 2) k0 = N - 2;
    if (k0 < 0) k0 = 0;
    double frac = seg - k0;
    frac = smoothstep(0, 1, frac);

    double kf0 = (k0 == 0) ? (using_to ? 0.0 : 1.0)
                            : minb + hash01(k0, 9, p->seed + salt) * (1.0 - minb);
    double kf1 = (k0 + 1 == N - 1) ? (using_to ? 1.0 : 0.0)
                                    : minb + hash01(k0 + 1, 9, p->seed + salt) * (1.0 - minb);
    double brightness = kf0 + (kf1 - kf0) * frac;

    const buf_t *img = using_to ? to : from;
    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            uint32_t c = img->pix[i];
            uint8_t rr = (uint8_t)(px_r(c) * brightness);
            uint8_t gg = (uint8_t)(px_g(c) * brightness);
            uint8_t bb = (uint8_t)(px_b(c) * brightness);
            out->pix[i] = px_pack(px_a(c), rr, gg, bb);
        }
    }
}

/* ------------------------------------------------------------- axis-spin
 * The old image spins faster and faster around its own vertical (default)
 * or horizontal axis, foreshortening like a rotating card; once it's
 * spinning fast enough the "back face" (the new image) is what's showing,
 * and it slows back down to settle flat. The angle always ends on an odd
 * multiple of pi so the settled face is guaranteed to be "to" regardless
 * of axisspin_turns. The angle itself is driven through a fixed internal
 * ease-in-out (not whatever --easing the user picked) specifically so the
 * slow-fast-slow *spin* shape is guaranteed; three closely-spaced angle
 * samples are averaged per pixel as a cheap motion-blur approximation,
 * which is what actually keeps the fastest part of the spin from looking
 * like it's skipping frames. */
static void fx_axis_spin(const buf_t *from, const buf_t *to, buf_t *out, double t,
                          const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double total_angle = M_PI + p->axisspin_turns * 2 * M_PI;
    int vertical_axis = p->axisspin_vertical;
    double dt = 0.01;
    double tsamp[3] = { (t - dt) < 0 ? 0 : t - dt, t, (t + dt) > 1 ? 1 : t + dt };

    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double accr = 0, accg = 0, accb = 0;
            for (int s = 0; s < 3; s++) {
                double angle = total_angle * easing_apply(EASE_INOUT_CUBIC, tsamp[s]);
                double cv = cos(angle);
                double scale = fabs(cv);
                if (scale < 0.03) scale = 0.03;
                double shade = 0.3 + 0.7 * scale;
                const buf_t *face = (cv >= 0) ? from : to;
                double sx, sy;
                if (!vertical_axis) { sx = cx + (x - cx) / scale; sy = y; }
                else { sx = x; sy = cy + (y - cy) / scale; }
                if (sx >= 0 && sx < w - 1 && sy >= 0 && sy < h - 1) {
                    uint32_t c = buf_sample_bilinear(face, sx, sy);
                    accr += px_r(c) * shade; accg += px_g(c) * shade; accb += px_b(c) * shade;
                }
            }
            size_t i = (size_t)y * w + x;
            out->pix[i] = px_pack(255, (uint8_t)fmin(255, accr / 3), (uint8_t)fmin(255, accg / 3), (uint8_t)fmin(255, accb / 3));
        }
    }
}

/* ----------------------------------------------------------------- cube
 * The honest version of "spinning cube": a two-face card-flip (front =
 * "from", back = "to") using the same foreshortening trick as axis-spin,
 * plus a zoom that shrinks the card toward the middle of the spin and
 * grows it back out. A real 6-face perspective-textured cube (with
 * correctly projected side faces at grazing angles) needs an actual 3D
 * rasterizer; this gets the "it's spinning and flips to the new
 * wallpaper" feeling without pretending to be one. cube_spin_speed sets
 * how many extra full rotations happen before it settles. */
static void fx_cube(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    double cx = w / 2.0, cy = h / 2.0;
    double total_angle = M_PI + p->cube_spin_speed * 2 * M_PI;
    double et = easing_apply(EASE_INOUT_CUBIC, t);
    double angle = total_angle * et;
    double cv = cos(angle);
    double face_scale = fabs(cv);
    if (face_scale < 0.03) face_scale = 0.03;
    double zoom_bell = sin(M_PI * et); /* 0 at t=0/1, 1 at mid */
    double zoom_scale = 1.0 - p->cube_zoom * zoom_bell;
    double total_scale = face_scale * zoom_scale;
    if (total_scale < 0.03) total_scale = 0.03;
    double shade = 0.3 + 0.7 * face_scale;
    const buf_t *face = (cv >= 0) ? from : to;

    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            double sx = cx + (x - cx) / total_scale;
            double sy = cy + (y - cy) / total_scale;
            size_t i = (size_t)y * w + x;
            if (sx >= 0 && sx < w - 1 && sy >= 0 && sy < h - 1) {
                uint32_t c = buf_sample_bilinear(face, sx, sy);
                uint8_t rr = (uint8_t)fmin(255, px_r(c) * shade);
                uint8_t gg = (uint8_t)fmin(255, px_g(c) * shade);
                uint8_t bb = (uint8_t)fmin(255, px_b(c) * shade);
                out->pix[i] = px_pack(255, rr, gg, bb);
            } else {
                out->pix[i] = 0xFF000000u; /* space behind the spinning card */
            }
        }
    }
}

/* ------------------------------------------------------------- logo-sting
 * A broadcast-bumper-style sting: a logo/face image (tp->logo, loaded
 * once by main.c from --logo-path before rendering starts) pops into the
 * center, holds, then spins and grows until it fills the screen and
 * "passes" -- at which point the background underneath is already the
 * new wallpaper, so continuing forward reveals it. No logo configured?
 * Falls back to a plain fade rather than doing nothing. */
static void fx_logo_sting(const buf_t *from, const buf_t *to, buf_t *out, double t,
                           const tparams_t *p, int r0, int r1) {
    int w = from->w, h = from->h;
    if (!p->logo || !p->logo->pix || p->logo->w < 1) {
        for (int y = r0; y < r1; y++)
            for (int x = 0; x < w; x++) {
                size_t i = (size_t)y * w + x;
                out->pix[i] = px_lerp(from->pix[i], to->pix[i], t);
            }
        return;
    }

    double fade_end = p->logo_fadein_frac;
    double static_end = fade_end + p->logo_static_frac;
    double target_size = 0.35;

    double logo_scale, logo_alpha, logo_rot = 0;
    int revealed = 0;
    const buf_t *base_img = from;

    if (t < fade_end) {
        double u = fade_end > 0 ? t / fade_end : 1;
        u = easing_apply(EASE_OUT_BACK, u);
        logo_scale = target_size * (u < 0 ? 0 : u);
        logo_alpha = u < 0 ? 0 : (u > 1 ? 1 : u);
    } else if (t < static_end) {
        logo_scale = target_size;
        logo_alpha = 1.0;
    } else {
        double u = static_end < 1 ? (t - static_end) / (1 - static_end) : 1;
        if (u < 0) u = 0;
        if (u > 1) u = 1;
        double zoom_t = pow(u, 1.0 / fmax(0.1, p->logo_zoom_speed));
        double cover_scale = 2.2;
        logo_scale = target_size + (cover_scale - target_size) * zoom_t;
        logo_rot = zoom_t * 2 * M_PI * p->logo_spin_speed;
        logo_alpha = 1.0;
        if (logo_scale >= cover_scale * 0.85) { revealed = 1; base_img = to; }
        if (u > 0.85) {
            double fadeout = (u - 0.85) / 0.15;
            logo_alpha = 1.0 - fadeout;
            if (logo_alpha < 0) logo_alpha = 0;
        }
    }
    if (revealed) base_img = to;

    double cx = w / 2.0, cy = h / 2.0;
    double lw = p->logo->w, lh = p->logo->h;
    double logo_px = fmin(w, h) * logo_scale;
    double aspect_scale = logo_px / fmax(lw, lh);
    double cosr = cos(-logo_rot), sinr = sin(-logo_rot);

    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            uint32_t col = base_img->pix[i];
            if (logo_alpha > 0.003 && aspect_scale > 0.001) {
                double dx = x - cx, dy = y - cy;
                double rx = dx * cosr - dy * sinr;
                double ry = dx * sinr + dy * cosr;
                double lx = rx / aspect_scale + lw / 2.0;
                double ly = ry / aspect_scale + lh / 2.0;
                if (lx >= 0 && lx < lw - 1 && ly >= 0 && ly < lh - 1) {
                    uint32_t lc = buf_sample_bilinear(p->logo, lx, ly);
                    double la = (px_a(lc) / 255.0) * logo_alpha;
                    if (la > 0.003) col = px_lerp(col, lc, la);
                }
            }
            out->pix[i] = col;
        }
    }
}

/* ---------------------------------------------------------------- paper-plane
 * Stylized, not literal: this is NOT a geometric paper-fold simulation
 * (that's well beyond hand-rolled per-pixel 2D math) -- it's a small
 * rotated card carrying a cropped thumbnail of the image, flown along a
 * swooping path off-screen and back, which is the honest approximation
 * of "folds into a paper plane and flies around" achievable here. */
static void fx_paper_plane(const buf_t *from, const buf_t *to, buf_t *out, double t,
                            const tparams_t *p, int r0, int r1) {
    (void)p;
    int w = from->w, h = from->h;
    double cx0 = w / 2.0, cy0 = h / 2.0;
    double plane_size = fmin(w, h) * 0.22;

    double pA = 0.15, pB = 0.45, pC = 0.55, pD = 0.85;
    double plane_cx = cx0, plane_cy = cy0, plane_scale = 0, plane_rot = 0, plane_alpha = 0;
    int carrying_to = 0, show_plane = 1;
    const buf_t *base_img = from;

    if (t < pA) {
        double u = pA > 0 ? t / pA : 1;
        u = easing_apply(EASE_OUT_BACK, u);
        plane_scale = u < 0 ? 0 : u;
        plane_alpha = u < 0 ? 0 : (u > 1 ? 1 : u);
    } else if (t < pB) {
        double u = (t - pA) / (pB - pA);
        double eu = easing_apply(EASE_IN_CUBIC, u);
        double exit_x = w * 1.3, exit_y = -h * 0.3;
        plane_cx = cx0 + (exit_x - cx0) * eu;
        plane_cy = cy0 + (exit_y - cy0) * eu - h * 0.08 * sin(u * M_PI);
        plane_scale = 1.0 - 0.4 * eu;
        plane_rot = -0.5 * eu;
        plane_alpha = (u > 0.9) ? (1.0 - (u - 0.9) / 0.1) : 1.0;
    } else if (t < pC) {
        show_plane = 0;
        base_img = to;
    } else if (t < pD) {
        double u = (t - pC) / (pD - pC);
        double eu = easing_apply(EASE_OUT_CUBIC, u);
        double enter_x = -w * 0.3, enter_y = h * 1.3;
        plane_cx = enter_x + (cx0 - enter_x) * eu;
        plane_cy = enter_y + (cy0 - enter_y) * eu + h * 0.08 * sin(u * M_PI);
        plane_scale = 0.6 + 0.4 * eu;
        plane_rot = 0.5 * (1 - eu);
        plane_alpha = (u < 0.1) ? (u / 0.1) : 1.0;
        base_img = to;
        carrying_to = 1;
    } else {
        double u = (t - pD) / (1 - pD);
        u = easing_apply(EASE_IN_CUBIC, u);
        plane_scale = 1.0 + u * 2.0;
        plane_alpha = 1.0 - u;
        base_img = to;
        carrying_to = 1;
        if (u > 0.6) show_plane = 0;
    }

    const buf_t *thumb_src = carrying_to ? to : from;
    double half_size = (plane_size * plane_scale) / 2.0;
    double cosr = cos(-plane_rot), sinr = sin(-plane_rot);
    double crop = fmin(thumb_src->w, thumb_src->h) * 0.8;

    for (int y = r0; y < r1; y++) {
        for (int x = 0; x < w; x++) {
            size_t i = (size_t)y * w + x;
            uint32_t col = base_img->pix[i];
            if (show_plane && plane_alpha > 0.01 && half_size > 0.5) {
                double dx = x - plane_cx, dy = y - plane_cy;
                double rx = dx * cosr - dy * sinr;
                double ry = dx * sinr + dy * cosr;
                if (rx >= -half_size && rx < half_size && ry >= -half_size && ry < half_size) {
                    double su = (rx + half_size) / (2 * half_size);
                    double sv = (ry + half_size) / (2 * half_size);
                    double sx = thumb_src->w / 2.0 - crop / 2.0 + su * crop;
                    double sy = thumb_src->h / 2.0 - crop / 2.0 + sv * crop;
                    uint32_t tc = buf_sample_bilinear(thumb_src, sx, sy);
                    double edge_dist = fmin(half_size - fabs(rx), half_size - fabs(ry));
                    if (edge_dist < 3.0) tc = px_lerp(0xFFFFFFFFu, tc, edge_dist / 3.0);
                    col = px_lerp(col, tc, plane_alpha);
                }
            }
            out->pix[i] = col;
        }
    }
}

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
    { "oblique-left",  fx_oblique_left,  "diagonal wipe (angle configurable via oblique_angle)" },
    { "oblique-right", fx_oblique_right, "diagonal wipe (angle configurable via oblique_angle)" },
    { "emerge-left",  fx_emerge_left,   "new image emerges from the left edge" },
    { "emerge-right", fx_emerge_right,  "new image emerges from the right edge" },
    { "emerge-up",    fx_emerge_up,     "new image emerges from the top edge" },
    { "emerge-down",  fx_emerge_down,   "new image emerges from the bottom edge" },
    { "circle-out",   fx_circle_out,    "hard circle grows from origin (default center)" },
    { "circle-in",    fx_circle_in,     "hard circle shrinks to origin (default center)" },
    { "grow-center",  fx_grow_center,   "soft/feathered circle grows from origin" },
    { "diamond",      fx_diamond,       "diamond grows from origin" },
    { "clock",        fx_clock,         "radial clock-hand sweep around origin" },
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
    { "stripes-left",  fx_stripes_left,  "vertical bars cascade in top-down, left to right" },
    { "stripes-right", fx_stripes_right, "vertical bars cascade in top-down, right to left" },
    { "stripes-up",    fx_stripes_up,    "horizontal bars cascade in left-right, bottom to top" },
    { "stripes-down",  fx_stripes_down,  "horizontal bars cascade in left-right, top to bottom" },
    { "stripes-oblique-left",  fx_stripes_oblique_left,  "diagonal cascade of bars (angle: oblique_angle)" },
    { "stripes-oblique-right", fx_stripes_oblique_right, "diagonal cascade of bars, mirrored" },
    { "panes-left",  fx_panes_left,  "N vertical panes each wipe open left-to-right, in sync" },
    { "panes-right", fx_panes_right, "N vertical panes each wipe open right-to-left, in sync" },
    { "panes-up",    fx_panes_up,    "N horizontal panes each wipe open bottom-to-top, in sync" },
    { "panes-down",  fx_panes_down,  "N horizontal panes each wipe open top-to-bottom, in sync" },
    { "fire-ring",     fx_fire_ring,     "clean radial fire front from origin (formerly \"burn\")" },
    { "burn",          fx_burn,          "irregular burning patches merge and consume the old image" },
    { "full-swing-forward",  fx_full_swing_forward,  "old image swings away, hinged at the screen edge" },
    { "full-swing-backward", fx_full_swing_backward, "new image swings in, hinged at the screen edge" },
    { "half-swing-forward",  fx_half_swing_forward,  "old image swings away, hinged at a custom pivot_pct" },
    { "half-swing-backward", fx_half_swing_backward, "new image swings in, hinged at a custom pivot_pct" },
    { "page-turn-left",  fx_page_turn_left,  "book-style: left page curls over the center spine" },
    { "page-turn-right", fx_page_turn_right, "book-style: right page curls over the center spine" },
    { "page-turn-up",    fx_page_turn_up,    "book-style: top page curls over the center spine" },
    { "page-turn-down",  fx_page_turn_down,  "book-style: bottom page curls over the center spine" },
    { "shatter",       fx_shatter,       "old image breaks into irregular glass-like pieces and falls" },
    { "matrix",        fx_matrix,        "staggered column wipe with a sinusoidal edge (formerly \"melt\")" },
    { "melt",          fx_melt,          "old image goes smudgy and sags/drips away like goo" },
    { "roll-away-up",    fx_roll_away_up,    "old image rolls away, seam travels upward" },
    { "roll-away-down",  fx_roll_away_down,  "old image rolls away, seam travels downward" },
    { "roll-away-left",  fx_roll_away_left,  "old image rolls away, seam travels left" },
    { "roll-away-right", fx_roll_away_right, "old image rolls away, seam travels right" },
    { "carpet-up",    fx_carpet_up,    "new image rolls in like a carpet, seam travels upward" },
    { "carpet-down",  fx_carpet_down,  "new image rolls in like a carpet, seam travels downward" },
    { "carpet-left",  fx_carpet_left,  "new image rolls in like a carpet, seam travels left" },
    { "carpet-right", fx_carpet_right, "new image rolls in like a carpet, seam travels right" },
    { "bubbles",     fx_bubbles,     "soft circles bloom at random spots/times and merge" },
    { "ripple",      fx_ripple,      "water-droplet ripple blurs the two images together" },
    { "flicker",     fx_flicker,     "dying-bulb flicker to black, then flickers new image in" },
    { "axis-spin",   fx_axis_spin,   "old image spins faster then slower around an axis" },
    { "cube",        fx_cube,        "two-face spinning-card cube flip with zoom" },
    { "logo-sting",  fx_logo_sting,  "broadcast-style logo bumper (needs --logo-path)" },
    { "paper-plane", fx_paper_plane, "folds into a paper plane, flies off and back" },
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
