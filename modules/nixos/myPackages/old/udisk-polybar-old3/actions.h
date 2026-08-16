#ifndef ACTIONS_H
#define ACTIONS_H

#include <X11/Xlib.h>
#include "device.h"
#include "mtp.h"

/* Mount/unmount/eject/power-off, with notifications wired to the
 * NOTIFY_ON_* toggles. No confirmation dialog and no Display needed
 * -- these are the shared low-level actions used both by menu
 * dispatch (after any configured confirmation) and by the daemon's
 * automount path. Return 1 on success, 0 on failure. */
int action_perform_mount(Device *d, char **out_mount_point);
int action_perform_unmount(Device *d, int force);
int action_perform_eject(Device *d);
int action_perform_power_off(Device *d);

/* Unlocks the LUKS container `d` represents (must have d->is_locked
 * set). Prompts for a passphrase (checking the session-keyring cache
 * first if enabled for this device), then attempts to mount the
 * resulting cleartext filesystem immediately. Notifications wired to
 * the NOTIFY_ON_UNLOCK_ and NOTIFY_ON_MOUNT_ toggles. */
void action_unlock_device(Display *dpy, int x, int y, Device *d);

/* Locks the container behind cleartext row `d` (must have
 * d->parent_luks_path set) -- unmounts first if needed. */
void action_lock_device(Display *dpy, int x, int y, Device *d);

/* Opens a phone's action menu (Mount/Unmount/Open in File Manager/
 * Copy Mount Path/Reload/custom entries) -- same shape as
 * action_open_device_menu but for an MtpDevice. */
void action_open_mtp_menu(Display *dpy, int x, int y, MtpDevice *m);

/* Opens the per-device popup menu at (x, y) and blocks until the user
 * picks something or cancels, performing whatever was picked
 * (including any configured confirmation dialog) before returning. */
void action_open_device_menu(Display *dpy, int x, int y, Device *d, DeviceList *list);

/* Opens the non-device-specific menu: Mount ISO, Detach ISO, launch
 * disk utility, reload, custom generic entries. */
void action_open_generic_menu(Display *dpy, int x, int y, DeviceList *list);

/* Signals a running --daemon process (if any) to refresh usage and
 * re-render immediately, used by the Reload menu rows. Silently does
 * nothing if no daemon is running. */
void action_signal_daemon_reload(void);

#endif /* ACTIONS_H */
