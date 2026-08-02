#ifndef CURSOR_SCALER_SVG_LOADER_H
#define CURSOR_SCALER_SVG_LOADER_H

#include <stdbool.h>

/*
 * Truly lossless cursor scaling.
 *
 * Standard Xcursor themes only ship pre-rasterized bitmaps (no matter what
 * the upstream design tool was authored in), so libXcursor / XRender can
 * never give us more detail than whatever bitmap size the theme shipped.
 * If the user points us at the *source* SVG for their cursor (many themes,
 * including Catppuccin, publish these in their git repo / a "svg" or
 * "src" directory alongside the compiled xcursor theme) we rasterize it
 * on demand at the exact on-screen pixel size every time the zoom level
 * changes, which is genuinely lossless at any scale.
 *
 * This entire module compiles to nothing (and svg_available() always
 * returns false) when built without librsvg + cairo development files.
 */

typedef struct SvgCursor SvgCursor;

/* Returns true if this build was compiled with librsvg/cairo support. */
bool svg_support_built(void);

/* Loads (parses) an SVG file. Returns NULL on failure. */
SvgCursor *svg_cursor_load(const char *path);

void svg_cursor_free(SvgCursor *svg);

/*
 * Rasterizes the SVG into a freshly malloc'd buffer of premultiplied
 * 32-bit ARGB pixels (native endian), width*height*4 bytes, stride =
 * width*4. Caller must free() the returned buffer. Returns NULL on
 * failure.
 */
unsigned char *svg_cursor_render(SvgCursor *svg, int width, int height);

#endif /* CURSOR_SCALER_SVG_LOADER_H */
