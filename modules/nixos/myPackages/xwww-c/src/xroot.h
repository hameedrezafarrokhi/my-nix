#ifndef XWWW_XROOT_H
#define XWWW_XROOT_H

#include "buffer.h"

typedef struct {
    char name[64];
    int x, y, w, h;
} monitor_t;

/* Connect to the X server, resolve root window/visual/depth. Must be
 * called once before anything else in this module. Returns 0 on success. */
int xroot_init(void);
void xroot_shutdown(void);

/* Overall root window (virtual screen) size, in pixels. */
void xroot_get_size(int *w, int *h);

/* Enumerate monitors (RandR if available, else Xinerama, else one
 * monitor == whole root). Returns count, fills up to max entries. */
int xroot_get_monitors(monitor_t *out, int max);

/* Capture the currently-displayed root window pixels into `out` (newly
 * allocated). This is how xwww gets a "from" frame to transition out of
 * without needing to remember anything between runs -- it just grabs
 * whatever is on screen right now, whether that was set by xwww, feh,
 * nitrogen, or nothing at all. Returns 0 on success. */
int xroot_capture(buf_t *out, int x, int y, int w, int h);

/* Reclaim whatever root pixmap a *previous* xwww run left behind (same
 * _XROOTPMAP_ID/ESETROOT_PMAP_ID trick feh/hsetroot use). Call this once,
 * before the first xroot_push_frame() of a run. Frames pushed by *this*
 * process after that are reclaimed automatically and cheaply (we own
 * them, so it's a plain XFreePixmap, no property round-trips needed). */
void xroot_reclaim_previous(void);

/* Push one frame as the real, live root background: creates a pixmap,
 * draws `full_canvas` (must cover the whole virtual screen -- see
 * xroot_get_size()) into it, sets it as the window background, clears the
 * window (so plain, non-compositing X11 shows it immediately), and
 * updates _XROOTPMAP_ID / ESETROOT_PMAP_ID so compositors and
 * desktop-background tools (which redraw from that property, not from
 * raw root-window pixels) pick it up too. This is called for *every*
 * frame of an animation, not just the last one -- that atom update is
 * what makes a frame actually visible under a compositor or a desktop
 * shell, so there's no cheaper "preview only" path that still shows up
 * on screen in general. Returns 0 on success. */
int xroot_push_frame(const buf_t *full_canvas);

#endif
