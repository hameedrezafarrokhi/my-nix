#ifndef PROGRESS_H
#define PROGRESS_H

#include <X11/Xlib.h>

/*
 * progress.h
 *
 * A small, purely-informational progress window (no input handling --
 * nothing to click, closes itself when the transfer finishes), used
 * for MTP upload/download. Visually consistent with xmenu/xinput
 * (same MENU_FONT/MENU_COLOR_* from config.h).
 */

typedef struct ProgressWindow ProgressWindow;

/* Opens the window at (x, y) with a title line. Returns NULL on
 * failure -- callers should treat that as "no progress display this
 * time", not fail the transfer over it (progress_update/close are
 * both safe no-ops on NULL). */
ProgressWindow *progress_open(Display *dpy, int x, int y, const char *title);

/* Updates the current-file line and the bar (fraction clamped to
 * 0.0-1.0). Internally throttled (safe to call as often as you like,
 * e.g. after every read() chunk) so it doesn't redraw more often than
 * the eye can usefully perceive. */
void progress_update(ProgressWindow *pw, const char *current_file, double fraction);

void progress_close(ProgressWindow *pw);

#endif /* PROGRESS_H */
