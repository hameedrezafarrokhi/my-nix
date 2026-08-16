#ifndef XMENU_H
#define XMENU_H

#include <X11/Xlib.h>

/* A menu item. Leaf items (submenu == NULL) return `id` when selected.
 * Items with a submenu open a nested popup instead of being directly
 * selectable. `label` == NULL renders as a thin separator line.
 * `enabled` == 0 renders the item greyed out and unselectable. */
typedef struct MenuItem {
    const char *label;
    int id;
    int enabled;
    struct MenuItem *submenu;
    int submenu_count;
} MenuItem;

/* Opens (and blocks on) a popup menu at screen coordinates (x, y).
 *
 * Returns the `id` of the selected leaf item, or -1 if the user
 * cancelled (Escape, or clicked outside every menu in the chain).
 * If `out_label` is non-NULL, *out_label is set to the selected leaf's
 * label on success (points into the caller's `items` array, do not
 * free), or NULL on cancel.
 *
 * `dpy` must already be open (XOpenDisplay). xmenu_show does not close
 * it -- the caller owns the Display for the lifetime of the process.
 */
int xmenu_show(Display *dpy, int x, int y, MenuItem *items, int count,
               const char **out_label);

#endif /* XMENU_H */
