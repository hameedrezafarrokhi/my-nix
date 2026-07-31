#include "buffer.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

buf_t buf_alloc(int w, int h) {
    buf_t b;
    b.w = w > 0 ? w : 1;
    b.h = h > 0 ? h : 1;
    b.pix = calloc((size_t)b.w * b.h, sizeof(uint32_t));
    return b;
}

void buf_free(buf_t *b) {
    if (!b) return;
    free(b->pix);
    b->pix = NULL;
    b->w = b->h = 0;
}

buf_t buf_dup(const buf_t *src) {
    buf_t b = buf_alloc(src->w, src->h);
    memcpy(b.pix, src->pix, (size_t)src->w * src->h * sizeof(uint32_t));
    return b;
}

void buf_fill(buf_t *b, uint32_t argb) {
    size_t n = (size_t)b->w * b->h;
    for (size_t i = 0; i < n; i++) b->pix[i] = argb;
}

buf_t buf_resize(const buf_t *src, int neww, int newh) {
    buf_t out = buf_alloc(neww, newh);
    double sx = (double)src->w / neww, sy = (double)src->h / newh;
    for (int y = 0; y < newh; y++) {
        double srcy = (y + 0.5) * sy - 0.5;
        for (int x = 0; x < neww; x++) {
            double srcx = (x + 0.5) * sx - 0.5;
            out.pix[(size_t)y * neww + x] = buf_sample_bilinear(src, srcx, srcy);
        }
    }
    return out;
}

buf_t buf_crop(const buf_t *src, int x, int y, int w, int h) {
    buf_t out = buf_alloc(w, h);
    for (int yy = 0; yy < h; yy++)
        for (int xx = 0; xx < w; xx++)
            out.pix[(size_t)yy * w + xx] = buf_get(src, x + xx, y + yy);
    return out;
}

void buf_paste(buf_t *dst, const buf_t *src, int x, int y) {
    for (int yy = 0; yy < src->h; yy++) {
        int dy = y + yy;
        if (dy < 0 || dy >= dst->h) continue;
        for (int xx = 0; xx < src->w; xx++) {
            int dx = x + xx;
            if (dx < 0 || dx >= dst->w) continue;
            dst->pix[(size_t)dy * dst->w + dx] = src->pix[(size_t)yy * src->w + xx];
        }
    }
}

uint32_t buf_sample_bilinear(const buf_t *src, double x, double y) {
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x > src->w - 1) x = src->w - 1;
    if (y > src->h - 1) y = src->h - 1;
    int x0 = (int)floor(x), y0 = (int)floor(y);
    int x1 = x0 + 1 < src->w ? x0 + 1 : x0;
    int y1 = y0 + 1 < src->h ? y0 + 1 : y0;
    double fx = x - x0, fy = y - y0;

    uint32_t p00 = buf_get(src, x0, y0);
    uint32_t p10 = buf_get(src, x1, y0);
    uint32_t p01 = buf_get(src, x0, y1);
    uint32_t p11 = buf_get(src, x1, y1);

    uint32_t top = px_lerp(p00, p10, fx);
    uint32_t bot = px_lerp(p01, p11, fx);
    return px_lerp(top, bot, fy);
}
