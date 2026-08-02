#ifndef DAEMON_H
#define DAEMON_H

#include <X11/Xlib.h>

/* Runs forever (until SIGINT/SIGTERM), printing the polybar module
 * text once at startup and again whenever KDE Connect's device state
 * actually changes. Meant for polybar's `tail = true` script mode.
 *
 * `show_battery` controls whether the numeric battery percentage is
 * printed next to the icon (see config.h SHOW_BATTERY_PERCENT_DEFAULT
 * / the -b CLI flag); `show_name` does the same for the device name
 * (SHOW_DEVICE_NAME_DEFAULT / --show-name) -- neither changes what's
 * queried over D-Bus, only what's printed. `json_mode` switches the
 * printed format from polybar markup to one JSON array per line (see
 * render.h's render_module_json).
 *
 * While idle, the process blocks in poll() on the D-Bus socket fd
 * (plus an internal self-pipe used for clean signal-based shutdown):
 * genuinely 0% CPU, not fast polling. Returns a process exit code. */
int daemon_run(Display *dpy, const char *self_exe, int show_battery, int show_name, int json_mode);

#endif /* DAEMON_H */
