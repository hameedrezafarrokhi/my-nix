#ifndef XINPUT_H
#define XINPUT_H

#include <X11/Xlib.h>

/* A tiny modal single-line text box, visually consistent with
 * xmenu/fmenu (same MENU_FONT/MENU_COLOR_* from config.h), used
 * anywhere a typed value is needed rather than a pick-from-a-list --
 * currently just the symlink leaf name for "Change Mount Point".
 *
 * `initial` pre-fills and pre-selects... actually just pre-fills
 * (cursor placed at the end) an editable default so most of the time
 * the user only has to glance and hit Enter.
 *
 * Enter confirms (returns a malloc'd string, possibly empty).
 * Escape cancels (returns NULL). */
char *xinput_show(Display *dpy, int x, int y, const char *prompt, const char *initial);

#endif /* XINPUT_H */
