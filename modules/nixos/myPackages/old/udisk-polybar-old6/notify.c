#include <stdio.h>
#include <dbus/dbus.h>

#include "notify.h"
#include "config.h"

/* UDisks lives on the SYSTEM bus (see udisks.c's ud_conn()), but
 * org.freedesktop.Notifications lives on the SESSION bus like any
 * other desktop-integration service -- so this keeps its own
 * separate connection rather than reusing ud_conn(). */
static DBusConnection *notify_conn(void) {
    static DBusConnection *conn = NULL;
    static int tried = 0;
    if (!conn && !tried) {
        tried = 1;
        DBusError err;
        dbus_error_init(&err);
        conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
        if (dbus_error_is_set(&err)) {
            dbus_error_free(&err);
            conn = NULL;
        }
    }
    return conn;
}

void ud_notify(const char *summary, const char *body) {
    DBusConnection *conn = notify_conn();
    if (!conn) return; /* no session bus available -- silently skip */

    DBusMessage *msg = dbus_message_new_method_call(
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        "Notify");
    if (!msg) return;

    DBusMessageIter args;
    dbus_message_iter_init_append(msg, &args);

    const char *app_name = NOTIFY_APP_NAME;
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &app_name);

    dbus_uint32_t replaces_id = 0;
    dbus_message_iter_append_basic(&args, DBUS_TYPE_UINT32, &replaces_id);

    const char *icon = NOTIFY_ICON_NAME;
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &icon);

    const char *s = summary ? summary : "";
    const char *b = body ? body : "";
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &s);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &b);

    DBusMessageIter actions;
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "s", &actions);
    dbus_message_iter_close_container(&args, &actions);

    DBusMessageIter hints;
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "{sv}", &hints);
    dbus_message_iter_close_container(&args, &hints);

    dbus_int32_t timeout = NOTIFY_TIMEOUT_MS;
    dbus_message_iter_append_basic(&args, DBUS_TYPE_INT32, &timeout);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(conn, msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return;
    }
    if (reply) dbus_message_unref(reply);
}
