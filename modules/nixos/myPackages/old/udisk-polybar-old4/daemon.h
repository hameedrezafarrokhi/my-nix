#ifndef DAEMON_H
#define DAEMON_H

/* Runs forever (until SIGINT/SIGTERM), printing the polybar module
 * text once at startup and again whenever the device list actually
 * changes. Meant for polybar's `tail = true` script mode.
 *
 * While idle, blocks in poll() on the D-Bus socket fd, a self-pipe
 * used for signal-based shutdown/reload, and (only in
 * USAGE_CHECK_MODE_PERIODIC) a bounded timeout for the next usage
 * re-check -- genuinely 0% CPU between wakeups, not fast polling.
 *
 * `json_mode` switches the printed format from polybar markup to a
 * JSON array per line. Returns a process exit code. */
int daemon_run(int json_mode);

#endif /* DAEMON_H */
