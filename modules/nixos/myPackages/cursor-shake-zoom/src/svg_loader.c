#include "svg_loader.h"
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_RSVG

#include <librsvg/rsvg.h>
#include <cairo.h>

struct SvgCursor {
    RsvgHandle *handle;
};

bool svg_support_built(void) { return true; }

SvgCursor *svg_cursor_load(const char *path) {
    GError *err = NULL;
    RsvgHandle *handle = rsvg_handle_new_from_file(path, &err);
    if (!handle) {
        if (err) g_error_free(err);
        return NULL;
    }

    SvgCursor *svg = calloc(1, sizeof(SvgCursor));
    svg->handle = handle;
    return svg;
}

void svg_cursor_free(SvgCursor *svg) {
    if (!svg) return;
    if (svg->handle) g_object_unref(svg->handle);
    free(svg);
}

unsigned char *svg_cursor_render(SvgCursor *svg, int width, int height) {
    if (!svg || !svg->handle || width <= 0 || height <= 0) return NULL;

    cairo_surface_t *surface =
        cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
    if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
        cairo_surface_destroy(surface);
        return NULL;
    }

    cairo_t *cr = cairo_create(surface);

    /* rsvg_handle_render_cairo scales to whatever the current transform
     * is, so we just scale by target/intrinsic size and let it rasterize
     * directly at the requested resolution - no intermediate bitmap. */
    double doc_w = 0, doc_h = 0;
#if LIBRSVG_CHECK_VERSION(2, 52, 0)
    RsvgRectangle viewport = {0, 0, width, height};
    GError *err = NULL;
    if (!rsvg_handle_render_document(svg->handle, cr, &viewport, &err)) {
        if (err) g_error_free(err);
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        return NULL;
    }
#else
    RsvgDimensionData dim;
    rsvg_handle_get_dimensions(svg->handle, &dim);
    doc_w = dim.width > 0 ? dim.width : width;
    doc_h = dim.height > 0 ? dim.height : height;
    cairo_scale(cr, (double)width / doc_w, (double)height / doc_h);
    if (!rsvg_handle_render_cairo(svg->handle, cr)) {
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        return NULL;
    }
#endif

    cairo_surface_flush(surface);

    int stride = cairo_image_surface_get_stride(surface);
    unsigned char *src = cairo_image_surface_get_data(surface);
    unsigned char *out = malloc((size_t)width * height * 4);
    if (out) {
        for (int y = 0; y < height; y++) {
            memcpy(out + (size_t)y * width * 4, src + (size_t)y * stride, (size_t)width * 4);
        }
    }

    cairo_destroy(cr);
    cairo_surface_destroy(surface);
    return out;
}

#else /* !HAVE_RSVG */

bool svg_support_built(void) { return false; }
SvgCursor *svg_cursor_load(const char *path) { (void)path; return NULL; }
void svg_cursor_free(SvgCursor *svg) { (void)svg; }
unsigned char *svg_cursor_render(SvgCursor *svg, int width, int height) {
    (void)svg; (void)width; (void)height;
    return NULL;
}

#endif /* HAVE_RSVG */
