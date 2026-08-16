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

/* Tracks which command mounted which phone (PID + mount point), keyed
 * by a device identity string (serial, or "bus:dev" if the device
 * reported no serial). Needed because Mount and Unmount are two
 * different short-lived processes in general -- the PID that mounted
 * a phone has to survive somewhere between them. Also how a
 * `--daemon` run recognizes "this phone disappeared while still
 * mounted" and cleans up after it. */
void state_set_mtp_mount(const char *device_key, pid_t pid, const char *mount_point);
void state_remove_mtp_mount(const char *device_key);
/* Returns 1 and fills *out_pid / *out_mount_point (malloc'd, caller
 * frees) if an entry exists, 0 otherwise (outputs left untouched). */
int state_get_mtp_mount(const char *device_key, pid_t *out_pid, char **out_mount_point);
/* Every currently-recorded device_key, for the daemon's "did any
 * mounted phone disappear" sweep. Malloc'd array of malloc'd strings;
 * caller frees each then the array. */
char **state_list_mtp_mounts(int *out_count);

/* Same idea, for tracking a spawned scrcpy process per device (so
 * "Run/Stop scrcpy" in the Android menu works correctly from a fresh
 * one-shot process, and so a still-running scrcpy can be found and
 * offered a Stop even after the phone was unplugged and replugged --
 * MTP mount tracking's reasoning applies identically here). 0 as a
 * pid means "not tracked/not running". */
void state_set_scrcpy(const char *device_key, pid_t pid);
void state_remove_scrcpy(const char *device_key);
pid_t state_get_scrcpy(const char *device_key);

#endif /* STATE_FILE_H */
