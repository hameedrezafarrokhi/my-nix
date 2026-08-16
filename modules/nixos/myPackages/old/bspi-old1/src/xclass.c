#include "xclass.h"
#include "common.h"

#include <stdlib.h>
#include <string.h>

#include <xcb/xcb.h>

struct xclass_ctx {
    xcb_connection_t *conn;
    xcb_atom_t atom_net_wm_name;
    xcb_atom_t atom_utf8_string;
};

static xcb_atom_t intern_atom(xcb_connection_t *conn, const char *name) {
    xcb_intern_atom_cookie_t cookie = xcb_intern_atom(conn, 0, (uint16_t)strlen(name), name);
    xcb_intern_atom_reply_t *reply = xcb_intern_atom_reply(conn, cookie, NULL);
    xcb_atom_t atom = reply ? reply->atom : XCB_ATOM_NONE;
    free(reply);
    return atom;
}

xclass_ctx_t *xclass_open(void) {
    xclass_ctx_t *ctx = malloc(sizeof(*ctx));
    if (!ctx) return NULL;

    ctx->conn = xcb_connect(NULL, NULL);
    if (!ctx->conn || xcb_connection_has_error(ctx->conn)) {
        LOGW("could not open X connection for WM_CLASS lookups "
             "(className fallback will be unavailable)");
        if (ctx->conn) xcb_disconnect(ctx->conn);
        free(ctx);
        return NULL;
    }

    ctx->atom_net_wm_name = intern_atom(ctx->conn, "_NET_WM_NAME");
    ctx->atom_utf8_string = intern_atom(ctx->conn, "UTF8_STRING");
    return ctx;
}

void xclass_close(xclass_ctx_t *ctx) {
    if (!ctx) return;
    if (ctx->conn) xcb_disconnect(ctx->conn);
    free(ctx);
}

int xclass_broken(xclass_ctx_t *ctx) {
    if (!ctx || !ctx->conn) return 1;
    return xcb_connection_has_error(ctx->conn) != 0;
}

char *xclass_get(xclass_ctx_t *ctx, uint32_t window_id, char *buf, size_t buflen) {
    if (!ctx || !ctx->conn || buflen == 0) return NULL;

    xcb_get_property_cookie_t cookie = xcb_get_property(
        ctx->conn, 0, (xcb_window_t)window_id,
        XCB_ATOM_WM_CLASS, XCB_ATOM_STRING, 0, 2048);

    xcb_generic_error_t *err = NULL;
    xcb_get_property_reply_t *reply = xcb_get_property_reply(ctx->conn, cookie, &err);

    if (err) {
        /* Most commonly BadWindow because the window closed between
         * bspwm reporting it and us asking X about it - completely
         * expected under rapid open/close churn, not an error worth
         * logging loudly. */
        free(err);
        free(reply);
        return NULL;
    }
    if (!reply) return NULL;

    int len = xcb_get_property_value_length(reply);
    if (len <= 0) { free(reply); return NULL; }

    const char *data = xcb_get_property_value(reply);
    /* WM_CLASS is two NUL-separated strings: "instance", "class". We
     * want the second one - the general class - to match what bspwm's
     * own `className` field would have given us. */
    const char *nul = memchr(data, '\0', (size_t)len);
    const char *class_start;
    size_t class_len;
    if (nul && (size_t)(nul - data) + 1 < (size_t)len) {
        class_start = nul + 1;
        const char *nul2 = memchr(class_start, '\0', (size_t)len - (size_t)(class_start - data));
        class_len = nul2 ? (size_t)(nul2 - class_start) : (size_t)len - (size_t)(class_start - data);
    } else {
        /* No instance/class split found - fall back to treating the
         * whole value as the class, better than nothing. */
        class_start = data;
        class_len = (size_t)len;
    }

    if (class_len == 0) { free(reply); return NULL; }
    if (class_len >= buflen) class_len = buflen - 1;
    memcpy(buf, class_start, class_len);
    buf[class_len] = '\0';

    free(reply);
    return buf;
}

/* Fetches a STRING/UTF8_STRING property and copies it (truncated) into
 * buf. Returns 1 on success, 0 if unset/errored. */
static int get_text_property(xcb_connection_t *conn, xcb_window_t win, xcb_atom_t atom,
                              xcb_atom_t type, char *buf, size_t buflen) {
    xcb_get_property_cookie_t cookie = xcb_get_property(conn, 0, win, atom, type, 0, 2048);
    xcb_generic_error_t *err = NULL;
    xcb_get_property_reply_t *reply = xcb_get_property_reply(conn, cookie, &err);
    if (err) { free(err); free(reply); return 0; }
    if (!reply) return 0;

    int len = xcb_get_property_value_length(reply);
    if (len <= 0 || reply->type == XCB_ATOM_NONE) { free(reply); return 0; }

    const char *data = xcb_get_property_value(reply);
    size_t n = (size_t)len;
    if (n >= buflen) n = buflen - 1;
    memcpy(buf, data, n);
    buf[n] = '\0';
    free(reply);
    return 1;
}

char *xclass_get_title(xclass_ctx_t *ctx, uint32_t window_id, char *buf, size_t buflen) {
    if (!ctx || !ctx->conn || buflen == 0) return NULL;
    xcb_window_t win = (xcb_window_t)window_id;

    if (ctx->atom_net_wm_name != XCB_ATOM_NONE && ctx->atom_utf8_string != XCB_ATOM_NONE) {
        if (get_text_property(ctx->conn, win, ctx->atom_net_wm_name, ctx->atom_utf8_string,
                               buf, buflen)) {
            return buf;
        }
    }
    /* Fall back to the older, plain-STRING WM_NAME. */
    if (get_text_property(ctx->conn, win, XCB_ATOM_WM_NAME, XCB_ATOM_STRING, buf, buflen)) {
        return buf;
    }
    return NULL;
}
