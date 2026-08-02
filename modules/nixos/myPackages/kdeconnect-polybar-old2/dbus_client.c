/*
 * dbus_client.c
 *
 * All D-Bus plumbing for talking to org.kde.kdeconnect.
 *
 * IMPORTANT: name/type/isReachable/isTrusted/hasPairingRequests on the
 * device interface, and charge/isMounted on the battery/sftp
 * sub-interfaces, are Qt *properties*, not plain methods. They must be
 * read via the standard org.freedesktop.DBus.Properties.Get call, not
 * a direct method call with the property's name (that's what `qdbus`
 * does transparently under the hood, which is why a naive 1:1
 * translation of `qdbus service path iface.propertyName` into a raw
 * method call fails silently and returns garbage defaults).
 *
 * Since I can't introspect a live kdeconnect instance from here, each
 * getter below tries Properties.Get first and falls back to a plain
 * method call if that fails -- belt and suspenders, in case a given
 * kdeconnect version exposes something as a real method instead.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dbus/dbus.h>

#include "dbus_client.h"
#include "config.h"

#define KDECONNECT_SERVICE "org.kde.kdeconnect"
#define PROPERTIES_IFACE   "org.freedesktop.DBus.Properties"

static DBusConnection *g_conn = NULL;

DBusConnection *kdc_conn(void) {
    if (!g_conn) {
        DBusError err;
        dbus_error_init(&err);
        g_conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
        if (dbus_error_is_set(&err)) {
            fprintf(stderr, "polybar-kdeconnect: D-Bus connection failed: %s\n", err.message);
            dbus_error_free(&err);
            exit(1);
        }
    }
    return g_conn;
}

/* ------------------------------------------------------------------ */
/* low-level method calls                                              */
/* ------------------------------------------------------------------ */

DBusMessage *kdc_call(const char *path, const char *iface, const char *method,
                      const char *string_arg) {
    DBusMessage *msg = dbus_message_new_method_call(KDECONNECT_SERVICE, path, iface, method);
    if (!msg) return NULL;

    if (string_arg) {
        dbus_message_append_args(msg, DBUS_TYPE_STRING, &string_arg, DBUS_TYPE_INVALID);
    }

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(
        kdc_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return NULL;
    }
    return reply;
}

void kdc_action(const char *path, const char *iface, const char *method, const char *string_arg) {
    DBusMessage *reply = kdc_call(path, iface, method, string_arg);
    if (reply) dbus_message_unref(reply);
}

static DBusMessage *properties_get(const char *path, const char *iface, const char *prop) {
    DBusMessage *msg = dbus_message_new_method_call(KDECONNECT_SERVICE, path, PROPERTIES_IFACE, "Get");
    if (!msg) return NULL;

    dbus_message_append_args(msg, DBUS_TYPE_STRING, &iface, DBUS_TYPE_STRING, &prop, DBUS_TYPE_INVALID);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(
        kdc_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return NULL;
    }
    return reply;
}

/* ------------------------------------------------------------------ */
/* property-aware getters (Properties.Get, falling back to a plain     */
/* method call)                                                        */
/* ------------------------------------------------------------------ */

int kdc_get_string(const char *path, const char *iface, const char *name, char **out) {
    *out = NULL;

    DBusMessage *reply = properties_get(path, iface, name);
    if (reply) {
        DBusMessageIter iter, variant;
        dbus_message_iter_init(reply, &iter);
        if (dbus_message_iter_get_arg_type(&iter) == DBUS_TYPE_VARIANT) {
            dbus_message_iter_recurse(&iter, &variant);
            if (dbus_message_iter_get_arg_type(&variant) == DBUS_TYPE_STRING) {
                char *val = NULL;
                dbus_message_iter_get_basic(&variant, &val);
                *out = val ? strdup(val) : strdup("");
                dbus_message_unref(reply);
                return 1;
            }
        }
        dbus_message_unref(reply);
    }

    /* fallback: plain method call */
    reply = kdc_call(path, iface, name, NULL);
    if (!reply) return 0;
    char *val = NULL;
    int ok = dbus_message_get_args(reply, NULL, DBUS_TYPE_STRING, &val, DBUS_TYPE_INVALID);
    if (ok) *out = val ? strdup(val) : strdup("");
    dbus_message_unref(reply);
    return ok;
}

int kdc_get_bool(const char *path, const char *iface, const char *name, int *out) {
    *out = 0;

    DBusMessage *reply = properties_get(path, iface, name);
    if (reply) {
        DBusMessageIter iter, variant;
        dbus_message_iter_init(reply, &iter);
        if (dbus_message_iter_get_arg_type(&iter) == DBUS_TYPE_VARIANT) {
            dbus_message_iter_recurse(&iter, &variant);
            if (dbus_message_iter_get_arg_type(&variant) == DBUS_TYPE_BOOLEAN) {
                dbus_bool_t val = FALSE;
                dbus_message_iter_get_basic(&variant, &val);
                *out = val ? 1 : 0;
                dbus_message_unref(reply);
                return 1;
            }
        }
        dbus_message_unref(reply);
    }

    reply = kdc_call(path, iface, name, NULL);
    if (!reply) return 0;
    dbus_bool_t val = FALSE;
    int ok = dbus_message_get_args(reply, NULL, DBUS_TYPE_BOOLEAN, &val, DBUS_TYPE_INVALID);
    if (ok) *out = val ? 1 : 0;
    dbus_message_unref(reply);
    return ok;
}

int kdc_get_int(const char *path, const char *iface, const char *name, int *out) {
    *out = -1;

    DBusMessage *reply = properties_get(path, iface, name);
    if (reply) {
        DBusMessageIter iter, variant;
        dbus_message_iter_init(reply, &iter);
        if (dbus_message_iter_get_arg_type(&iter) == DBUS_TYPE_VARIANT) {
            dbus_message_iter_recurse(&iter, &variant);
            int vtype = dbus_message_iter_get_arg_type(&variant);
            if (vtype == DBUS_TYPE_INT32) {
                dbus_int32_t val = -1;
                dbus_message_iter_get_basic(&variant, &val);
                *out = (int)val;
                dbus_message_unref(reply);
                return 1;
            } else if (vtype == DBUS_TYPE_UINT32) {
                dbus_uint32_t val = 0;
                dbus_message_iter_get_basic(&variant, &val);
                *out = (int)val;
                dbus_message_unref(reply);
                return 1;
            } else if (vtype == DBUS_TYPE_BYTE) {
                unsigned char val = 0;
                dbus_message_iter_get_basic(&variant, &val);
                *out = (int)val;
                dbus_message_unref(reply);
                return 1;
            }
        }
        dbus_message_unref(reply);
    }

    reply = kdc_call(path, iface, name, NULL);
    if (!reply) return 0;
    dbus_int32_t val = -1;
    int ok = dbus_message_get_args(reply, NULL, DBUS_TYPE_INT32, &val, DBUS_TYPE_INVALID);
    if (ok) *out = (int)val;
    dbus_message_unref(reply);
    return ok;
}

/* ------------------------------------------------------------------ */
/* device enumeration -- daemon.devices() is a genuine method, not a   */
/* property, and matches the original working script's zero-arg call. */
/* ------------------------------------------------------------------ */

char **kdc_get_device_ids(int *count) {
    *count = 0;
    DBusMessage *reply = kdc_call(KDC_DAEMON_PATH, KDC_DAEMON_IFACE, "devices", NULL);
    if (!reply) return NULL;

    DBusMessageIter iter, sub;
    dbus_message_iter_init(reply, &iter);
    if (dbus_message_iter_get_arg_type(&iter) != DBUS_TYPE_ARRAY) {
        dbus_message_unref(reply);
        return NULL;
    }
    dbus_message_iter_recurse(&iter, &sub);

    char **ids = NULL;
    int n = 0;
    while (dbus_message_iter_get_arg_type(&sub) == DBUS_TYPE_STRING) {
        char *s = NULL;
        dbus_message_iter_get_basic(&sub, &s);
        char **grown = realloc(ids, sizeof(char *) * (n + 1));
        if (!grown) break;
        ids = grown;
        ids[n++] = strdup(s ? s : "");
        dbus_message_iter_next(&sub);
    }

    dbus_message_unref(reply);
    *count = n;
    return ids;
}

void kdc_free_device_ids(char **ids, int count) {
    if (!ids) return;
    for (int i = 0; i < count; i++) free(ids[i]);
    free(ids);
}

int kdc_get_bool_any(const char *path, const char *iface, const char **names, int name_count, int *out) {
    for (int i = 0; i < name_count; i++) {
        if (kdc_get_bool(path, iface, names[i], out)) return 1;
    }
    *out = 0;
    return 0;
}

int kdc_is_paired(const char *devpath, int *out) {
    static const char *names[] = { "isPaired", "isTrusted", "trusted" };
    return kdc_get_bool_any(devpath, KDC_DEVICE_IFACE, names, 3, out);
}

int kdc_get_verification_key(const char *devpath, char **out) {
    return kdc_get_string(devpath, KDC_DEVICE_IFACE, "verificationKey", out);
}

int kdc_get_signal_bars(const char *devpath, int *out_bars) {
    *out_bars = -1;

    char connpath[340];
    snprintf(connpath, sizeof(connpath), "%s/connectivity_report", devpath);

    int strength = -1;
    if (!kdc_get_int(connpath, KDC_CONNECTIVITY_IFACE, "cellularNetworkStrength", &strength)) {
        return 0;
    }
    if (strength < 0) return 0;
    if (strength > 4) strength = 4;

    *out_bars = strength;
    return 1;
}

char **kdc_get_connected_device_ids(int *count) {
    *count = 0;
    int all_count = 0;
    char **all_ids = kdc_get_device_ids(&all_count);
    if (!all_ids) return NULL;

    char **connected = NULL;
    int n = 0;
    for (int i = 0; i < all_count; i++) {
        char path[300];
        kdc_device_path(path, sizeof(path), all_ids[i]);
        int reachable = 0, trusted = 0;
        kdc_get_bool(path, KDC_DEVICE_IFACE, "isReachable", &reachable);
        kdc_is_paired(path, &trusted);
        if (reachable && trusted) {
            char **grown = realloc(connected, sizeof(char *) * (size_t)(n + 1));
            if (!grown) break;
            connected = grown;
            connected[n++] = strdup(all_ids[i]);
        }
    }

    kdc_free_device_ids(all_ids, all_count);
    *count = n;
    return connected;
}

int kdc_get_int_array(const char *path, const char *iface, const char *name, int **out, int *out_count) {
    *out = NULL;
    *out_count = 0;

    DBusMessage *reply = NULL;
    DBusMessageIter array_iter;
    int have_array = 0;

    DBusMessage *prop_reply = properties_get(path, iface, name);
    if (prop_reply) {
        DBusMessageIter iter, variant;
        dbus_message_iter_init(prop_reply, &iter);
        if (dbus_message_iter_get_arg_type(&iter) == DBUS_TYPE_VARIANT) {
            dbus_message_iter_recurse(&iter, &variant);
            if (dbus_message_iter_get_arg_type(&variant) == DBUS_TYPE_ARRAY) {
                array_iter = variant;
                have_array = 1;
                reply = prop_reply;
            }
        }
        if (!have_array) dbus_message_unref(prop_reply);
    }

    if (!have_array) {
        reply = kdc_call(path, iface, name, NULL);
        if (!reply) return 0;
        DBusMessageIter iter;
        dbus_message_iter_init(reply, &iter);
        if (dbus_message_iter_get_arg_type(&iter) != DBUS_TYPE_ARRAY) {
            dbus_message_unref(reply);
            return 0;
        }
        array_iter = iter;
        have_array = 1;
    }

    DBusMessageIter sub;
    dbus_message_iter_recurse(&array_iter, &sub);

    int *vals = NULL;
    int n = 0;
    while (dbus_message_iter_get_arg_type(&sub) == DBUS_TYPE_INT32) {
        dbus_int32_t v = 0;
        dbus_message_iter_get_basic(&sub, &v);
        int *grown = realloc(vals, sizeof(int) * (size_t)(n + 1));
        if (!grown) break;
        vals = grown;
        vals[n++] = (int)v;
        dbus_message_iter_next(&sub);
    }

    dbus_message_unref(reply);
    *out = vals;
    *out_count = n;
    return n > 0;
}

int kdc_call_int_with_int_arg(const char *path, const char *iface, const char *method, int arg, int *out) {
    *out = -1;
    DBusMessage *msg = dbus_message_new_method_call(KDECONNECT_SERVICE, path, iface, method);
    if (!msg) return 0;

    dbus_int32_t a = arg;
    dbus_message_append_args(msg, DBUS_TYPE_INT32, &a, DBUS_TYPE_INVALID);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(kdc_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return 0;
    }
    if (!reply) return 0;

    dbus_int32_t val = -1;
    int ok = dbus_message_get_args(reply, NULL, DBUS_TYPE_INT32, &val, DBUS_TYPE_INVALID);
    if (ok) *out = (int)val;
    dbus_message_unref(reply);
    return ok;
}

int kdc_call_string_with_int_arg(const char *path, const char *iface, const char *method, int arg, char **out) {
    *out = NULL;
    DBusMessage *msg = dbus_message_new_method_call(KDECONNECT_SERVICE, path, iface, method);
    if (!msg) return 0;

    dbus_int32_t a = arg;
    dbus_message_append_args(msg, DBUS_TYPE_INT32, &a, DBUS_TYPE_INVALID);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(kdc_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return 0;
    }
    if (!reply) return 0;

    char *val = NULL;
    int ok = dbus_message_get_args(reply, NULL, DBUS_TYPE_STRING, &val, DBUS_TYPE_INVALID);
    if (ok) *out = val ? strdup(val) : strdup("");
    dbus_message_unref(reply);
    return ok;
}
