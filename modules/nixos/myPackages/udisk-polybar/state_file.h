#ifndef STATE_FILE_H
#define STATE_FILE_H

#include <sys/types.h> /* pid_t */

/* Persists which device the per-device menu was most recently opened
 * for, so a one-shot invocation with no -i (e.g. a generic keybinding)
 * has a sensible default when more than one device is attached. Same
 * pattern as the kdeconnect module's last-device file. */
void save_last_device(const char *device_id);
char *load_last_device(void); /* malloc'd, or NULL */

/* Custom mount-point symlink mappings (see config.h's "CHANGE MOUNT
 * POINT" section), keyed by filesystem UUID so they survive
 * reboots/replugs even though the UDisks object path does not.
 * state_set_symlink(uuid, NULL) or ("") removes the mapping. */
char *state_get_symlink(const char *uuid); /* malloc'd, or NULL if none configured */
void state_set_symlink(const char *uuid, const char *path);

/* Tracks which loop devices this module attached via "Mount ISO"
 * (vs. the many other /dev/loopN devices a typical desktop already
 * has running for snap packages, flatpak runtimes, squashfs images,
 * etc, none of which anyone wants cluttering the polybar module) --
 * this is what lets ISO rows show in the bar without also showing
 * every unrelated loop device on the system. Keyed by UDisks object
 * path, which is stable for as long as that specific loop device
 * stays attached (the only time it needs to be looked up). */
void state_mark_iso_loop(const char *object_path);
void state_unmark_iso_loop(const char *object_path);
int state_is_tracked_iso_loop(const char *object_path); /* 1/0 */

/* Daemon PID file, so a one-shot "Reload" menu click can signal the
 * running --daemon process to re-check usage and re-render right
 * away instead of waiting for its next timer tick. */
void save_daemon_pid(void);
pid_t load_daemon_pid(void); /* 0 if none recorded */

#endif /* STATE_FILE_H */
