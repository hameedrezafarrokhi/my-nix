#ifndef DBUS_CLIENT_H
#define DBUS_CLIENT_H

#include <stdio.h>
#include <stddef.h>
#include <dbus/dbus.h>

#define KDC_DAEMON_PATH        "/modules/kdeconnect"
#define KDC_DAEMON_IFACE       "org.kde.kdeconnect.daemon"
#define KDC_DEVICE_IFACE       "org.kde.kdeconnect.device"
#define KDC_BATTERY_IFACE      "org.kde.kdeconnect.device.battery"
#define KDC_FINDMYPHONE_IFACE  "org.kde.kdeconnect.device.findmyphone"
#define KDC_SHARE_IFACE        "org.kde.kdeconnect.device.share"
#define KDC_SFTP_IFACE         "org.kde.kdeconnect.device.sftp"
#define KDC_PING_IFACE         "org.kde.kdeconnect.device.ping"
#define KDC_CONNECTIVITY_IFACE "org.kde.kdeconnect.device.connectivity_report"
#define KDC_CLIPBOARD_IFACE    "org.kde.kdeconnect.device.clipboard"

/* Shared session-bus connection (opened lazily on first use). */
DBusConnection *kdc_conn(void);

/* Low-level blocking method call. `string_arg` may be NULL for
 * zero-arg calls. Returns the reply (caller must dbus_message_unref
 * it), or NULL on error/timeout. */
DBusMessage *kdc_call(const char *path, const char *iface, const char *method,
                      const char *string_arg);

/* Fire-and-discard version of kdc_call, for actions whose return value
 * we don't care about (ping, unpair, requestPair, ...). */
void kdc_action(const char *path, const char *iface, const char *method, const char *string_arg);

/* Property-aware getters: try org.freedesktop.DBus.Properties.Get
 * first, fall back to a plain method call. Return 1 on success (with
 * *out populated), 0 on failure (with *out set to a safe default). */
int kdc_get_string(const char *path, const char *iface, const char *name, char **out);
int kdc_get_bool(const char *path, const char *iface, const char *name, int *out);
int kdc_get_int(const char *path, const char *iface, const char *name, int *out);

/* Tries several candidate property names in turn (e.g. "isReachable"
 * then "reachable"), returning on the first one that resolves to a
 * real value. Used where I'm not fully certain which casing/naming a
 * given kdeconnect version actually exposes. */
int kdc_get_bool_any(const char *path, const char *iface, const char **names, int name_count, int *out);

/* Confirmed real property name is "isPaired" (there is no
 * "isTrusted"). Kept as a single shared helper so every call site
 * agrees, with isTrusted/trusted kept as harmless extra fallbacks. */
int kdc_is_paired(const char *devpath, int *out);

/* verificationKey() -- the short string KDE Connect shows on both
 * ends during pairing for the user to visually compare. Caller frees
 * *out. Returns 1 on success. */
int kdc_get_verification_key(const char *devpath, char **out);

/* Enumerates currently known device IDs. Returns a malloc'd array of
 * malloc'd strings; free with kdc_free_device_ids. */
char **kdc_get_device_ids(int *count);
void kdc_free_device_ids(char **ids, int count);

/* Same, but filtered to devices currently reachable+trusted (i.e.
 * actually connected right now). */
char **kdc_get_connected_device_ids(int *count);

/* Reads an array-of-int32 property (Properties.Get first, falling
 * back to a plain zero-arg method call), e.g. connectivity_report's
 * list of active SIM subscription IDs on dual-SIM devices. Returns a
 * malloc'd array via *out (caller frees), 1 on success with at least
 * one element, 0 otherwise. */
int kdc_get_int_array(const char *path, const char *iface, const char *name, int **out, int *out_count);

/* Calls a method that takes one int32 argument and returns one int32
 * / string respectively (e.g. connectivity_report's
 * signalStrength(subscriptionId) / networkType(subscriptionId), which
 * take a real argument and so can't go through the property-fallback
 * getters above). Returns 1 on success. */
int kdc_call_int_with_int_arg(const char *path, const char *iface, const char *method, int arg, int *out);
int kdc_call_string_with_int_arg(const char *path, const char *iface, const char *method, int arg, char **out);

/* SIM signal strength (0-4 bars) via the connectivity_report plugin,
 * confirmed live: a plain int property "cellularNetworkStrength" at
 * <devpath>/connectivity_report -- no multi-SIM subscription-id
 * indirection needed, unlike my first guess. Returns 1 with *out_bars
 * set on success, 0 (with *out_bars = -1) if the device has no
 * connectivity_report plugin at all (e.g. a tablet or desktop). */
int kdc_get_signal_bars(const char *devpath, int *out_bars);

static inline void kdc_device_path(char *buf, size_t buflen, const char *id) {
    snprintf(buf, buflen, "%s/devices/%s", KDC_DAEMON_PATH, id);
}

#endif /* DBUS_CLIENT_H */
