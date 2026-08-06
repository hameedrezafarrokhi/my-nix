/*
 * daemon.c
 *
 * The 0%-idle-CPU path, same overall shape as the kdeconnect module's
 * daemon.c: block in poll() on the D-Bus socket fd plus a self-pipe,
 * never a spawned timer thread. Two things are specific to disks:
 *
 *   - a bounded poll() timeout for USAGE_CHECK_MODE_PERIODIC, since
 *     that's a real timer (re-check mounted filesystems' free space
 *     every USAGE_CHECK_INTERVAL_SEC) rather than pure signal-driven
 *     work -- still just an idle wakeup, still a single statvfs() per
 *     mounted device, not a poll loop;
 *   - automount, which needs to fire exactly once per physical
 *     attachment, not on every PropertiesChanged that happens to
 *     follow (e.g. the user manually unmounting it later shouldn't
 *     immediately remount it). See seen-device tracking below.
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
#include "udisks.h"
#include "device.h"
#include "actions.h"
#include "render.h"
#include "notify.h"
#include "state_file.h"
#include "config.h"

#define PIPE_BYTE_EXIT   1
#define PIPE_BYTE_RELOAD 2

static int g_pipe[2] = { -1, -1 };

static void handle_term(int sig) {
    (void)sig;
    char b = PIPE_BYTE_EXIT;
    ssize_t w = write(g_pipe[1], &b, 1);
    (void)w;
}

static void handle_usr1(int sig) {
    (void)sig;
    char b = PIPE_BYTE_RELOAD;
    ssize_t w = write(g_pipe[1], &b, 1);
    (void)w;
}

static long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long)ts.tv_sec * 1000L + ts.tv_nsec / 1000000L;
}

typedef struct {
    int dirty;         /* any relevant signal seen, debounce before re-render */
    int structural;     /* specifically an InterfacesAdded/Removed, not just PropertiesChanged -- gates automount consideration */
    long last_ms;
} SignalState;

static DBusHandlerResult filter_cb(DBusConnection *conn, DBusMessage *msg, void *user_data) {
    (void)conn;
    SignalState *ss = (SignalState *)user_data;
    if (udisks_message_is_relevant_signal(msg)) {
        ss->dirty = 1;
        ss->last_ms = now_ms();
        if (dbus_message_is_signal(msg, "org.freedesktop.DBus.ObjectManager", "InterfacesAdded") ||
            dbus_message_is_signal(msg, "org.freedesktop.DBus.ObjectManager", "InterfacesRemoved")) {
            ss->structural = 1;
        }
    }
    return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

/* ------------------------------------------------------------------ */
/* seen-device tracking for automount                                   */
/* ------------------------------------------------------------------ */

static char **g_seen = NULL;
static int g_seen_count = 0;

static int seen_contains(const char *path) {
    for (int i = 0; i < g_seen_count; i++)
        if (!strcmp(g_seen[i], path)) return 1;
    return 0;
}
static void seen_add(const char *path) {
    g_seen = realloc(g_seen, sizeof(char *) * (g_seen_count + 1));
    g_seen[g_seen_count++] = strdup(path);
}
static void seen_prune_to(const DeviceList *list) {
    /* Drop anything from `seen` that isn't in the current list --
     * lets a future replug of the same device trigger automount
     * again, since it's a fresh attachment as far as the user's
     * concerned even if the UDisks object path happens to be
     * reused. */
    for (int i = 0; i < g_seen_count; ) {
        int still_present = 0;
        for (int j = 0; j < list->count; j++)
            if (!strcmp(g_seen[i], list->items[j].object_path)) { still_present = 1; break; }
        if (still_present) {
            i++;
        } else {
            free(g_seen[i]);
            g_seen[i] = g_seen[g_seen_count - 1];
            g_seen_count--;
        }
    }
}

static void consider_automount(DeviceList *list) {
    for (int i = 0; i < list->count; i++) {
        Device *d = &list->items[i];
        if (seen_contains(d->object_path)) continue;
        seen_add(d->object_path);
        if (!d->is_mounted && device_should_automount(d)) {
            action_perform_mount(d, NULL);
        }
    }
    seen_prune_to(list);
}

/* ------------------------------------------------------------------ */

static void print_state(const DeviceList *list, char **last, int json_mode) {
    /* render_bar/render_json both write straight to stdout, so build
     * into a buffer via a pipe-free approach: just always print --
     * dedup would need capturing stdout, which isn't worth it here
     * since a genuinely-unchanged render only happens right after an
     * unchanged periodic usage check, and printing that one extra
     * identical line costs nothing polybar-side (`tail = true` just
     * re-displays the same text). Kept `last` as an unused parameter
     * for interface symmetry with the kdeconnect module; may be wired
     * up to real dedup in a later round if it turns out to matter. */
    (void)last;
    if (json_mode) render_json(list);
    else render_bar(list);
    fflush(stdout);
}

int daemon_run(int json_mode) {
    save_daemon_pid();

    DBusConnection *conn = ud_conn();
    udisks_subscribe_signals();

    SignalState ss = { 0, 0, 0 };
    dbus_connection_add_filter(conn, filter_cb, &ss, NULL);

    int dbus_fd = -1;
    if (!dbus_connection_get_unix_fd(conn, &dbus_fd)) {
        fprintf(stderr, "polybar-udisks: could not get D-Bus connection fd\n");
        return 1;
    }

    if (pipe(g_pipe) != 0) {
        perror("polybar-udisks: pipe");
        return 1;
    }

    struct sigaction sa_term;
    memset(&sa_term, 0, sizeof(sa_term));
    sa_term.sa_handler = handle_term;
    sigaction(SIGINT, &sa_term, NULL);
    sigaction(SIGTERM, &sa_term, NULL);

    struct sigaction sa_usr1;
    memset(&sa_usr1, 0, sizeof(sa_usr1));
    sa_usr1.sa_handler = handle_usr1;
    sigaction(SIGUSR1, &sa_usr1, NULL);

    DeviceList list = { NULL, 0 };
    device_list_build(&list);
    consider_automount(&list);

    char *last = NULL;
    print_state(&list, &last, json_mode);

    long last_usage_check = now_ms();

    for (;;) {
        struct pollfd fds[2];
        fds[0].fd = dbus_fd; fds[0].events = POLLIN; fds[0].revents = 0;
        fds[1].fd = g_pipe[0]; fds[1].events = POLLIN; fds[1].revents = 0;

        int timeout_ms = -1;
        if (ss.dirty) timeout_ms = DAEMON_DEBOUNCE_MS;
#if USAGE_CHECK_MODE == USAGE_CHECK_MODE_PERIODIC
        else {
            long elapsed = now_ms() - last_usage_check;
            long remaining = (long)USAGE_CHECK_INTERVAL_SEC * 1000L - elapsed;
            timeout_ms = remaining > 0 ? (int)remaining : 0;
        }
#endif

        int pr = poll(fds, 2, timeout_ms);
        if (pr < 0) {
            if (errno == EINTR) continue;
            break;
        }

        if (fds[1].revents & POLLIN) {
            char b = 0;
            ssize_t n = read(g_pipe[0], &b, 1);
            (void)n;
            if (b == PIPE_BYTE_EXIT) break;
            if (b == PIPE_BYTE_RELOAD) {
                device_list_refresh_usage(&list);
                print_state(&list, &last, json_mode);
                last_usage_check = now_ms();
                continue;
            }
        }

        if (fds[0].revents & POLLIN) {
            dbus_connection_read_write(conn, 0);
            while (dbus_connection_dispatch(conn) == DBUS_DISPATCH_DATA_REMAINS) { }
        }

        if (ss.dirty && (now_ms() - ss.last_ms) >= DAEMON_DEBOUNCE_MS) {
            ss.dirty = 0;
            int was_structural = ss.structural;
            ss.structural = 0;
            device_list_build(&list);
            if (was_structural) consider_automount(&list);
            print_state(&list, &last, json_mode);
            last_usage_check = now_ms();
            continue;
        }

#if USAGE_CHECK_MODE == USAGE_CHECK_MODE_PERIODIC
        if (!ss.dirty && (now_ms() - last_usage_check) >= (long)USAGE_CHECK_INTERVAL_SEC * 1000L) {
            device_list_refresh_usage(&list);
            print_state(&list, &last, json_mode);
            last_usage_check = now_ms();
        }
#endif
    }

    close(g_pipe[0]);
    close(g_pipe[1]);
    free(last);
    device_list_free(&list);
    for (int i = 0; i < g_seen_count; i++) free(g_seen[i]);
    free(g_seen);
    return 0;
}
