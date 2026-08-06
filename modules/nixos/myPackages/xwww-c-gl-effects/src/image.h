#ifndef XWWW_IMAGE_H
#define XWWW_IMAGE_H

#include "buffer.h"

typedef enum {
    SCALE_FILL = 0,  /* cover + center-crop, no letterbox (default) */
    SCALE_FIT,       /* contain, letterbox with bg color */
    SCALE_STRETCH,   /* independent x/y scale to exactly fill canvas */
    SCALE_CENTER,    /* no scaling, centered, cropped/padded */
    SCALE_TILE       /* repeat at native resolution */
} scale_mode_t;

scale_mode_t scale_mode_from_name(const char *name);

/* Load an image file into an ARGB buffer at its native resolution.
 * Returns 0 on success. Uses Imlib2 for decode (png/jpg/bmp/webp/gif/...). */
int image_load(const char *path, buf_t *out);

/* Pick a random image file from a directory (non-recursive, common
 * image extensions). Caller frees the returned path. NULL on failure. */
char *image_pick_random(const char *dir_path);

/* List image filenames (not full paths) in `dir_path`, sorted
 * alphabetically -- used by slideshow mode's sequential order. Returns
 * the count and mallocs *out_list to an array of malloc'd strings;
 * caller frees each string then the array. 0 on an empty/bad directory. */
int image_list_sorted(const char *dir_path, char ***out_list);

/* Compose `src` onto a new canvas_w x canvas_h buffer per scale_mode.
 * bg_color used to fill letterbox/padding areas (SCALE_FIT/CENTER/TILE edges). */
buf_t image_compose_to_canvas(const buf_t *src, int canvas_w, int canvas_h,
                               scale_mode_t mode, uint32_t bg_color);

#endif
