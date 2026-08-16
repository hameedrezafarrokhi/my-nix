#ifndef FILEPICKER_H
#define FILEPICKER_H

#include <X11/Xlib.h>

/* Presents a searchable, scrollable directory browser (built on the
 * fmenu widget) starting at FILEPICKER_START_DIR. Directories descend
 * (or ".." goes back up); regular files are selectable.
 *
 * If `allow_multi` is 0, at most one file is ever returned (Enter
 * immediately confirms the highlighted file).
 *
 * If `allow_multi` is 1, Tab (or clicking) toggles a checkmark on
 * files within the *current* directory listing; Enter confirms every
 * checked file at once. Multi-select is per-folder, not across
 * folders, matching how most file pickers behave -- if you need files
 * from two different directories, run it twice.
 *
 * Returns a malloc'd array of malloc'd absolute file paths (caller
 * frees each string, then the array) and sets *out_count. Returns
 * NULL with *out_count == 0 if the user cancelled at any point.
 */
char **filepicker_choose(Display *dpy, int x, int y, int allow_multi, int *out_count);

/* Same as filepicker_choose(), but starts browsing at `start_dir`
 * (any path, "~" expanded) instead of the compile-time
 * FILEPICKER_START_DIR -- used wherever the sensible starting point
 * is only known at runtime (e.g. a phone's current MTP mount point). */
char **filepicker_choose_at(Display *dpy, int x, int y, const char *start_dir, int allow_multi, int *out_count);

/* Browse-for-a-folder: like filepicker_choose_at(), but for picking a
 * *destination directory* rather than a file -- only directories are
 * listed/navigable, and a "Select This Folder" entry at the top of
 * every listing confirms the current directory. Returns a malloc'd
 * absolute path, or NULL if cancelled. */
char *filepicker_choose_dir_at(Display *dpy, int x, int y, const char *start_dir);

#endif /* FILEPICKER_H */

