#ifndef BSPI_XCLASS_H
#define BSPI_XCLASS_H

#include <stddef.h>
#include <stdint.h>

/*
 * bspwm's own JSON tree usually already includes a client's WM_CLASS
 * (as `className`), but it can occasionally come back empty (some
 * Chromium-based apps set it late). The original script shelled out to
 * `xprop` to cover that case; this does the same lookup in-process over
 * a single long-lived X connection via libxcb, which is both much
 * cheaper (no fork+exec per window) and doesn't depend on parsing
 * xprop's text output.
 *
 * A bspwm client node's `id` is the underlying X window ID, so it can
 * be passed straight to xclass_get().
 */

typedef struct xclass_ctx xclass_ctx_t;

/* Connects to the X server named by $DISPLAY. Returns NULL on failure
 * (this is treated as non-fatal by the caller - bspi just runs without
 * the WM_CLASS fallback in that case). */
xclass_ctx_t *xclass_open(void);

void xclass_close(xclass_ctx_t *ctx);

/* Returns 1 if the connection has died (X server restarted, etc). The
 * caller should xclass_close() and xclass_open() again if so. */
int xclass_broken(xclass_ctx_t *ctx);

/* Looks up the WM_CLASS "class" component (the second of the two
 * NUL-separated strings in the property - the general application
 * class, e.g. "Firefox", not the specific instance name) for a window.
 * Writes into buf (NUL terminated, truncated to fit) and returns buf,
 * or returns NULL if the property is unset, the window is gone, or
 * anything else goes wrong. Never blocks longer than a normal X
 * round-trip and never crashes on a window that disappears mid-query -
 * that race is exactly the kind of thing that used to bring the old
 * script down. */
char *xclass_get(xclass_ctx_t *ctx, uint32_t window_id, char *buf, size_t buflen);

/* Looks up a window's title: tries _NET_WM_NAME (UTF8_STRING) first,
 * falling back to the older WM_NAME (STRING) if unset. Only called
 * when an [ignore] rule actually needs a title (see
 * ignore_table_needs_title()), since it's an extra round-trip nothing
 * else uses. Same failure handling as xclass_get(): returns NULL
 * rather than crashing on a window that's already gone. */
char *xclass_get_title(xclass_ctx_t *ctx, uint32_t window_id, char *buf, size_t buflen);

#endif /* BSPI_XCLASS_H */
