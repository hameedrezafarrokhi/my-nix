#ifndef ACTIONS_H
#define ACTIONS_H

#include <X11/Xlib.h>

/* Per-invocation position override for where a menu opens, resolved
 * from CLI flags (--at-pointer / --x / --y). Pass NULL to use
 * config.h's MENU_POSITION_AT_POINTER / MENU_FIXED_X / MENU_FIXED_Y
 * defaults untouched. force_pointer always wins over has_x/has_y if
 * both are somehow set. */
typedef struct {
    int has_x, has_y;
    int x, y;
    int force_pointer;
} MenuPos;

/* Per-device action menu. Invoked from a polybar click handler:
 *   polybar-kdeconnect -n NAME -i ID -m
 *
 * `dev_id` may be NULL, in which case the device is auto-resolved
 * (config.h DEFAULT_DEVICE_ID, then last-connected, then the only
 * connected device, then a "no devices connected" notice -- see
 * README).
 *
 * If the resolved device isn't paired yet, this shows a focused
 * "Pair Device" prompt instead of the normal action list (Ping, Find,
 * etc. are meaningless before pairing). A "Pair Device" entry is also
 * available in the normal menu for an already-paired device, purely
 * for convenience/re-pairing -- see SHOW_MENU_PAIR_DEVICE in
 * config.h. This makes a separate -p invocation unnecessary, though
 * it's kept working for compatibility (see action_show_pmenu).
 *
 * Queries battery/signal live via D-Bus when the menu opens. `pos`
 * may be NULL to use config.h defaults. */
void action_show_menu(Display *dpy, const char *dev_id, const char *dev_name, const MenuPos *pos);

/* Kept for backward compatibility with any embedded click handlers
 * from a previous build -- now just delegates to action_show_menu(),
 * which handles the unpaired case correctly on its own. */
void action_show_pmenu(Display *dpy, const char *dev_id, const char *dev_name, const MenuPos *pos);

/* Incoming pairing-request Accept/Reject prompt. Triggered
 * automatically by render_module() (see render.h) when a device
 * reports isPairRequestedByPeer -- not invoked from a click handler. */
void action_pairing_prompt(Display *dpy, const char *dev_name, const char *dev_id);

/* ------------------------------------------------------------------
 * Direct single-action entry points, for running one specific action
 * from the command line without opening the menu at all (e.g. a
 * dedicated keybinding for "ping my phone"). Each resolves the target
 * device the same way action_show_menu does when dev_id is NULL
 * (config.h DEFAULT_DEVICE_ID > live auto-detect), and silently does
 * nothing if no device can be resolved -- same "no devices connected"
 * notice as action_show_menu for the ones that open a menu of their
 * own (action_pair), otherwise just a no-op for the pure D-Bus calls.
 * ------------------------------------------------------------------ */

void action_ping(Display *dpy, const char *dev_id, const char *dev_name);
void action_find_device(Display *dpy, const char *dev_id, const char *dev_name);
void action_send_file(Display *dpy, const char *dev_id, const char *dev_name, const MenuPos *pos);
void action_browse_files(Display *dpy, const char *dev_id, const char *dev_name);
void action_send_clipboard(Display *dpy, const char *dev_id, const char *dev_name);
void action_pair(Display *dpy, const char *dev_id, const char *dev_name);
void action_unpair(Display *dpy, const char *dev_id, const char *dev_name);

/* Not device-specific -- these just launch the external app. */
void action_messages(void);
void action_open_app(void);

#endif /* ACTIONS_H */
