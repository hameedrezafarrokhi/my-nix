#ifndef NOTIFY_H
#define NOTIFY_H

/* Sends a desktop notification via a direct D-Bus call to
 * org.freedesktop.Notifications (the standard notification spec) --
 * no libnotify dependency, since libnotify itself is just a thin
 * wrapper around this same call. Requires a running notification
 * daemon (dunst, mako, etc). Failures are silent/best-effort: a
 * missing notification daemon should never crash or block the rest
 * of the program. */
void kdc_notify(const char *summary, const char *body);

#endif /* NOTIFY_H */
