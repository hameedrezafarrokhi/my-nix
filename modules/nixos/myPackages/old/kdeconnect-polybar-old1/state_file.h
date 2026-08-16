#ifndef STATE_FILE_H
#define STATE_FILE_H

/* Persists which device most recently transitioned to connected
 * (reachable+trusted), so a one-shot `-m` invocation with no -i/-n
 * (e.g. from a keybinding) has a sensible default when more than one
 * device is currently connected. Written by the daemon on every
 * connect transition; read by action_show_menu() when no device was
 * specified explicitly. */

void save_last_device(const char *device_id);

/* Returns a malloc'd device id, or NULL if none saved yet / unreadable. */
char *load_last_device(void);

#endif /* STATE_FILE_H */
