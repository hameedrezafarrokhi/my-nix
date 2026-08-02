/*
 * daemon.c
 *
 * The 0%-idle-CPU path. Instead of polybar polling us on an interval,
 * we run once as a long-lived process (polybar's `tail = true` mode)
 * and block in poll() until either:
 *   - the D-Bus session socket has data (a signal arrived), or
 *   - our self-pipe has a byte (SIGINT/SIGTERM asked us to exit).
 *
 * We deliberately don't use dbus_connection_read_write_dispatch()'s
 * own internal blocking wait for the idle case: libdbus's internal
 * poll wrapper retries transparently on EINTR, which can swallow a
 * signal and delay shutdown. Driving our own poll() over the raw fd
 * (plus the self-pipe) makes Ctrl+C / systemd stop reliably instant
 * regardless of what libdbus is doing internally.
 *
 * We don't try to interpret *which* D-Bus signal arrived (exact
 * signal names/interfaces differ across KDE Connect versions, and I
 * can't introspect a live instance from here) -- any signal whose
 * object path falls under /modules/kdeconnect just marks state dirty,
 * and we debounce a short quiet period before actually re-rendering,
 * so a burst of several property-changed signals produces one
 * printed line instead of several.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <poll.h>
#include <dbus/dbus.h>

#include "daemon.h"
#include "dbus_client.h"
#include "render.h"
#include "config.h"

static int g_exit_pipe[2] = { -1, -1 };

static void handle_signal(int sig) {
    (void)sig;
    char b = 1;
    ssize_t written = write(g_exit_pipe[1], &b, 1);
    (void)written; /* best effort; nothing sensible to do if this fails in a signal handler */
}

typedef struct {
    int dirty;
    long last_ms;
} SignalState;

static long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long)ts.tv_sec * 1000L + ts.tv_nsec / 1000000L;
}

static DBusHandlerResult filter_cb(DBusConnection *conn, DBusMessage *msg, void *user_data) {
    (void)conn;
    SignalState *ss = (SignalState *)user_data;
    const char *path = dbus_message_get_path(msg);
    if (path && strncmp(path, KDC_DAEMON_PATH, strlen(KDC_DAEMON_PATH)) == 0) {
        ss->dirty = 1;
        ss->last_ms = now_ms();
    }
    return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

static void render_and_print_if_changed(RenderState *state, char **last, int json_mode) {
    char *rendered = json_mode ? render_module_json(state) : render_module(state);
    if (!*last || strcmp(rendered, *last) != 0) {
        printf("%s\n", rendered);
        fflush(stdout);
        free(*last);
        *last = rendered;
    } else {
        free(rendered);
    }
}

int daemon_run(Display *dpy, const char *self_exe, int show_battery, int show_name, int json_mode) {
    DBusConnection *conn = kdc_conn();

    DBusError err;
    dbus_error_init(&err);
    char rule[256];
    snprintf(rule, sizeof(rule), "type='signal',path_namespace='%s'", KDC_DAEMON_PATH);
    dbus_bus_add_match(conn, rule, &err);
    if (dbus_error_is_set(&err)) {
        fprintf(stderr, "polybar-kdeconnect: failed to subscribe to signals: %s\n", err.message);
        dbus_error_free(&err);
        return 1;
    }
    dbus_connection_flush(conn);

    SignalState ss = { 0, 0 };
    dbus_connection_add_filter(conn, filter_cb, &ss, NULL);

    int dbus_fd = -1;
    if (!dbus_connection_get_unix_fd(conn, &dbus_fd)) {
        fprintf(stderr, "polybar-kdeconnect: could not get D-Bus connection fd\n");
        return 1;
    }

    if (pipe(g_exit_pipe) != 0) {
        perror("polybar-kdeconnect: pipe");
        return 1;
    }

    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_signal;
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);

    RenderState state;
    render_state_init(&state, dpy, self_exe, show_battery, show_name);

    char *last = NULL;
    render_and_print_if_changed(&state, &last, json_mode); /* initial state, printed at startup */

    for (;;) {
        struct pollfd fds[2];
        fds[0].fd = dbus_fd;
        fds[0].events = POLLIN;
        fds[0].revents = 0;
        fds[1].fd = g_exit_pipe[0];
        fds[1].events = POLLIN;
        fds[1].revents = 0;

        int timeout_ms = ss.dirty ? DAEMON_DEBOUNCE_MS : -1;
        int pr = poll(fds, 2, timeout_ms);

        if (pr < 0) {
            if (errno == EINTR) continue;
            break;
        }

        if (fds[1].revents & POLLIN) {
            break; /* SIGINT/SIGTERM */
        }

        if (fds[0].revents & POLLIN) {
            dbus_connection_read_write(conn, 0);
            while (dbus_connection_dispatch(conn) == DBUS_DISPATCH_DATA_REMAINS) {
                /* keep draining; filter_cb updates ss as messages pass through */
            }
        }

        if (ss.dirty && (now_ms() - ss.last_ms) >= DAEMON_DEBOUNCE_MS) {
            ss.dirty = 0;
            render_and_print_if_changed(&state, &last, json_mode);
        }
    }

    close(g_exit_pipe[0]);
    close(g_exit_pipe[1]);
    free(last);
    render_state_free(&state);
    return 0;
}
