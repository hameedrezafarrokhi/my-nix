#ifndef MTP_TRANSFER_H
#define MTP_TRANSFER_H

#include <X11/Xlib.h>

/*
 * mtp_transfer.h
 *
 * The actual file-copy engine behind the Android menu's Upload/
 * Download entries -- plain read()/write() against the mount point
 * (a real FUSE mount, so this works exactly like copying between two
 * ordinary directories; no MTP-protocol awareness needed here at
 * all, that's entirely the mount command's problem). Handles name
 * conflicts at the destination (a popup: Replace / Rename (numbered)
 * / Skip / Cancel Remaining -- or a fixed choice per
 * MTP_CONFLICT_MODE), shows a progress window, and sends one
 * completion notification.
 */

/* Copies `count` absolute file paths (as returned by
 * filepicker_choose()/filepicker_choose_at()) into `dest_dir`. Blocks
 * until done (or cancelled) -- callers run this synchronously in
 * response to a menu action, same as everything else in this
 * module. */
void mtp_transfer_copy_files(Display *dpy, int x, int y, char **src_paths, int count, const char *dest_dir);

#endif /* MTP_TRANSFER_H */
