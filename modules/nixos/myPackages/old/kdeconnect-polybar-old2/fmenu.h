#ifndef FMENU_H
#define FMENU_H

#include <X11/Xlib.h>

typedef struct {
    const char *label;      /* display text (also what's matched against) */
    int selectable;         /* 0 = shown but not selectable (e.g. ".." could still be selectable -- this is for future use) */
} FMenuEntry;

typedef struct {
    int index;              /* index into the original `entries` array that was
                              * confirmed on Enter with nothing checked, or -1
                              * if the user cancelled entirely. */
    int *checked;           /* malloc'd array of indices into `entries` that
                              * were toggled on with Tab (multi-select mode
                              * only). NULL if none were checked. Caller
                              * frees this. */
    int checked_count;
} FMenuResult;

/* Shows a searchable, scrollable popup list at screen coordinates
 * (x, y), clamped to fit within the screen height (unlike a plain
 * xmenu list, this never runs off-screen -- it scrolls instead).
 *
 * Typing filters `entries` by a simple case-insensitive subsequence
 * match against each label (fzf-style "does every typed character
 * appear in order", not fzf's exact scoring algorithm).
 *
 * Controls:
 *   type          filter
 *   Up/Down, j/k  move selection within filtered results (when the
 *                 query box is empty; j/k are literal characters
 *                 once you start typing, obviously)
 *   Tab           (multi_select only) toggle the highlighted entry
 *   Enter         confirm: the checked set if multi_select and
 *                 anything is checked, otherwise just the highlighted
 *                 entry
 *   Escape        cancel
 *
 * If `multi_select` is 0, result.checked is always NULL and only
 * result.index is meaningful.
 */
FMenuResult fmenu_show(Display *dpy, int x, int y, FMenuEntry *entries, int count, int multi_select);

#endif /* FMENU_H */
