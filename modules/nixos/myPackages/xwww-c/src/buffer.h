#ifndef XWWW_BUFFER_H
#define XWWW_BUFFER_H

#include <stdint.h>
#include <stddef.h>

/* Pixel format: 0xAARRGGBB, matches Imlib2 DATA32 and is what we
 * convert to the screen's native layout right before XPutImage/XShmPutImage. */
typedef struct {
    int w, h;
    uint32_t *pix; /* w*h, owned */
} buf_t;

buf_t  buf_alloc(int w, int h);
void   buf_free(buf_t *b);
buf_t  buf_dup(const buf_t *src);
void   buf_fill(buf_t *b, uint32_t argb);

static inline uint32_t buf_get(const buf_t *b, int x, int y) {
    if (x < 0) x = 0; else if (x >= b->w) x = b->w - 1;
    if (y < 0) y = 0; else if (y >= b->h) y = b->h - 1;
    return b->pix[(size_t)y * b->w + x];
}
static inline void buf_set(buf_t *b, int x, int y, uint32_t v) {
    if (x < 0 || y < 0 || x >= b->w || y >= b->h) return;
    b->pix[(size_t)y * b->w + x] = v;
}

/* Channel helpers on 0xAARRGGBB pixels */
static inline uint8_t px_a(uint32_t p) { return (uint8_t)(p >> 24); }
static inline uint8_t px_r(uint32_t p) { return (uint8_t)(p >> 16); }
static inline uint8_t px_g(uint32_t p) { return (uint8_t)(p >> 8); }
static inline uint8_t px_b(uint32_t p) { return (uint8_t)(p); }
static inline uint32_t px_pack(uint8_t a, uint8_t r, uint8_t g, uint8_t b) {
    return ((uint32_t)a << 24) | ((uint32_t)r << 16) | ((uint32_t)g << 8) | b;
}

static inline uint32_t px_lerp(uint32_t a, uint32_t b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    double ia = px_a(a) + (px_a(b) - (double)px_a(a)) * t;
    double ir = px_r(a) + (px_r(b) - (double)px_r(a)) * t;
    double ig = px_g(a) + (px_g(b) - (double)px_g(a)) * t;
    double ib = px_b(a) + (px_b(b) - (double)px_b(a)) * t;
    return px_pack((uint8_t)ia, (uint8_t)ir, (uint8_t)ig, (uint8_t)ib);
}

/* Bilinear sample of src at floating coords, clamped to edges. */
uint32_t buf_sample_bilinear(const buf_t *src, double x, double y);

/* Whole-buffer bilinear resize into a newly allocated buf_t. Used by the
 * render-scale perf knob (animate at reduced resolution, upscale for
 * display) and to derive a sub-region crop (neww==src region width etc). */
buf_t buf_resize(const buf_t *src, int neww, int newh);

/* Copy a w x h sub-rectangle starting at (x,y) out of src into a new buffer. */
buf_t buf_crop(const buf_t *src, int x, int y, int w, int h);

/* Paste `src` into `dst` at (x,y), clipped to dst's bounds. */
void buf_paste(buf_t *dst, const buf_t *src, int x, int y);

#endif
