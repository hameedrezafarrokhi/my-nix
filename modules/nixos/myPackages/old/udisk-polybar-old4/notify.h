#ifndef NOTIFY_H
#define NOTIFY_H

/* Sends a desktop notification via a direct D-Bus call to
 * org.freedesktop.Notifications (session bus) -- no libnotify
 * dependency. UDisks itself lives on the system bus (see udisks.h),
 * so this opens its own small session-bus connection. Failures are
 * silent/best-effort: a missing notification daemon should never
 * crash or block the rest of the program. */
void ud_notify(const char *summary, const char *body);

#endif /* NOTIFY_H */
