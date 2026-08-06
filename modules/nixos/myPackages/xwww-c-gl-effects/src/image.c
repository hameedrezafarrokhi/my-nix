#include "image.h"
#include <Imlib2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <dirent.h>
#include <math.h>
#include "util.h"

scale_mode_t scale_mode_from_name(const char *name) {
    if (!name) return SCALE_FILL;
    if (strcasecmp(name, "fit") == 0)     return SCALE_FIT;
    if (strcasecmp(name, "stretch") == 0) return SCALE_STRETCH;
    if (strcasecmp(name, "center") == 0)  return SCALE_CENTER;
    if (strcasecmp(name, "tile") == 0)    return SCALE_TILE;
    return SCALE_FILL;
}

int image_load(const char *path, buf_t *out) {
    Imlib_Load_Error err = IMLIB_LOAD_ERROR_NONE;
    Imlib_Image im = imlib_load_image_with_error_return(path, &err);
    if (!im || err != IMLIB_LOAD_ERROR_NONE) {
        fprintf(stderr, "xwww: failed to load image '%s' (imlib2 error %d)\n", path, (int)err);
        return -1;
    }
    imlib_context_set_image(im);
    int w = imlib_image_get_width();
    int h = imlib_image_get_height();
    imlib_image_set_has_alpha(1);
    DATA32 *data = imlib_image_get_data_for_reading_only();
    if (!data) {
        imlib_free_image();
        return -1;
    }
    *out = buf_alloc(w, h);
    memcpy(out->pix, data, (size_t)w * h * sizeof(uint32_t));
    imlib_free_image();
    return 0;
}

static int has_image_ext(const char *name) {
    static const char *exts[] = { ".png", ".jpg", ".jpeg", ".bmp", ".webp",
                                   ".gif", ".tiff", ".tif", ".ppm", ".pgm", NULL };
    const char *dot = strrchr(name, '.');
    if (!dot) return 0;
    for (int i = 0; exts[i]; i++)
        if (strcasecmp(dot, exts[i]) == 0) return 1;
    return 0;
}

static int strcmp_cmp(const void *a, const void *b) {
    return strcmp(*(char *const *)a, *(char *const *)b);
}

int image_list_sorted(const char *dir_path, char ***out_list) {
    DIR *d = opendir(dir_path);
    if (!d) { *out_list = NULL; return 0; }

    char **list = NULL;
    size_t n = 0, cap = 0;
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (e->d_name[0] == '.') continue;
        if (!has_image_ext(e->d_name)) continue;
        if (n == cap) {
            cap = cap ? cap * 2 : 16;
            list = realloc(list, cap * sizeof(char *));
        }
        list[n++] = strdup(e->d_name);
    }
    closedir(d);

    if (n > 1) qsort(list, n, sizeof(char *), strcmp_cmp);
    *out_list = list;
    return (int)n;
}

char *image_pick_random(const char *dir_path) {
    DIR *d = opendir(dir_path);
    if (!d) return NULL;

    char **list = NULL;
    size_t n = 0, cap = 0;
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (e->d_name[0] == '.') continue;
        if (!has_image_ext(e->d_name)) continue;
        if (n == cap) {
            cap = cap ? cap * 2 : 16;
            list = realloc(list, cap * sizeof(char *));
        }
        list[n++] = strdup(e->d_name);
    }
    closedir(d);
    if (n == 0) { free(list); return NULL; }

    int idx = xrng_int(0, (int)n - 1);
    char *chosen = list[idx];
    char *full = malloc(strlen(dir_path) + strlen(chosen) + 2);
    sprintf(full, "%s/%s", dir_path, chosen);
    for (size_t i = 0; i < n; i++) free(list[i]);
    free(list);
    return full;
}

static void blit_scaled_bilinear(const buf_t *src, buf_t *dst,
                                  int dst_x0, int dst_y0, int dst_w, int dst_h) {
    if (dst_w <= 0 || dst_h <= 0) return;
    double sx = (double)src->w / dst_w;
    double sy = (double)src->h / dst_h;
    for (int y = 0; y < dst_h; y++) {
        int dy = dst_y0 + y;
        if (dy < 0 || dy >= dst->h) continue;
        double srcy = (y + 0.5) * sy - 0.5;
        for (int x = 0; x < dst_w; x++) {
            int dx = dst_x0 + x;
            if (dx < 0 || dx >= dst->w) continue;
            double srcx = (x + 0.5) * sx - 0.5;
            dst->pix[(size_t)dy * dst->w + dx] = buf_sample_bilinear(src, srcx, srcy);
        }
    }
}

buf_t image_compose_to_canvas(const buf_t *src, int canvas_w, int canvas_h,
                               scale_mode_t mode, uint32_t bg_color) {
    buf_t out = buf_alloc(canvas_w, canvas_h);
    buf_fill(&out, bg_color);

    switch (mode) {
    case SCALE_STRETCH:
        blit_scaled_bilinear(src, &out, 0, 0, canvas_w, canvas_h);
        break;

    case SCALE_FIT: {
        double scale = fmin((double)canvas_w / src->w, (double)canvas_h / src->h);
        int w = (int)lround(src->w * scale);
        int h = (int)lround(src->h * scale);
        blit_scaled_bilinear(src, &out, (canvas_w - w) / 2, (canvas_h - h) / 2, w, h);
        break;
    }

    case SCALE_CENTER: {
        int x0 = (canvas_w - src->w) / 2;
        int y0 = (canvas_h - src->h) / 2;
        for (int y = 0; y < src->h; y++) {
            int dy = y0 + y;
            if (dy < 0 || dy >= canvas_h) continue;
            for (int x = 0; x < src->w; x++) {
                int dx = x0 + x;
                if (dx < 0 || dx >= canvas_w) continue;
                out.pix[(size_t)dy * canvas_w + dx] = src->pix[(size_t)y * src->w + x];
            }
        }
        break;
    }

    case SCALE_TILE: {
        for (int y = 0; y < canvas_h; y++)
            for (int x = 0; x < canvas_w; x++)
                out.pix[(size_t)y * canvas_w + x] = src->pix[(size_t)(y % src->h) * src->w + (x % src->w)];
        break;
    }

    case SCALE_FILL:
    default: {
        double scale = fmax((double)canvas_w / src->w, (double)canvas_h / src->h);
        int w = (int)lround(src->w * scale);
        int h = (int)lround(src->h * scale);
        blit_scaled_bilinear(src, &out, (canvas_w - w) / 2, (canvas_h - h) / 2, w, h);
        break;
    }
    }
    return out;
}
