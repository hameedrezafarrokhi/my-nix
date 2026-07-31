#include <dbus/dbus.h>

#include "notify.h"
#include "dbus_client.h"
#include "config.h"

void kdc_notify(const char *summary, const char *body) {
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

    /* empty actions array: "as" */
    DBusMessageIter actions;
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "s", &actions);
    dbus_message_iter_close_container(&args, &actions);

    /* empty hints dict: "a{sv}" */
    DBusMessageIter hints;
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "{sv}", &hints);
    dbus_message_iter_close_container(&args, &hints);

    dbus_int32_t timeout = NOTIFY_TIMEOUT_MS;
    dbus_message_iter_append_basic(&args, DBUS_TYPE_INT32, &timeout);

    DBusError err;
    dbus_error_init(&err);
    DBusMessage *reply = dbus_connection_send_with_reply_and_block(kdc_conn(), msg, DBUS_CALL_TIMEOUT_MS, &err);
    dbus_message_unref(msg);

    if (dbus_error_is_set(&err)) {
        /* No notification daemon running, etc -- not fatal. */
        dbus_error_free(&err);
        return;
    }
    if (reply) dbus_message_unref(reply);
}
