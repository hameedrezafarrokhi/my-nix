/*
 * actions.c
 *
 * Everything that happens after a click: building the popup menus
 * (xmenu.c) with the right rows for a given device's current state,
 * dispatching the selected row, and the handful of actions that
 * aren't simple 1:1 UDisks calls (change mount point, copy to
 * clipboard, mount/detach ISO, custom entries, the daemon-reload
 * signal).
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>

#include "actions.h"
#include "udisks.h"
#include "device.h"
#include "xmenu.h"
#include "xinput.h"
#include "filepicker.h"
#include "notify.h"
#include "render.h"
#include "state_file.h"
#include "config.h"

enum {
    ACT_MOUNT = 1,
    ACT_UNMOUNT,
    ACT_EJECT,
    ACT_POWER_OFF,
    ACT_OPEN_FILE_MANAGER,
    ACT_CHANGE_MOUNT_POINT,
    ACT_REMOVE_MOUNT_POINT,
    ACT_COPY_MOUNT_PATH,
    ACT_RELOAD,
    ACT_CUSTOM_BASE      = 1000,

    ACT_GENERIC_MOUNT_ISO   = 2000,
    ACT_GENERIC_DISK_UTILITY,
    ACT_GENERIC_RELOAD_ALL,
    ACT_GENERIC_DETACH_BASE = 3000,
    ACT_GENERIC_CUSTOM_BASE = 4000,
};

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */

static void add_info(MenuItem *items, int *n, const char *label) {
    items[*n] = (MenuItem){ label, -1, 0, NULL, 0 };
    (*n)++;
}
static void add_action(MenuItem *items, int *n, const char *label, int id, int enabled) {
    items[*n] = (MenuItem){ label, id, enabled, NULL, 0 };
    (*n)++;
}
static void add_sep(MenuItem *items, int *n) {
    items[*n] = (MenuItem){ NULL, -1, 0, NULL, 0 };
    (*n)++;
}

static int confirm_dialog(Display *dpy, int x, int y, const char *question) {
    MenuItem items[3] = {
        { question, -1, 0, NULL, 0 },
        { "Yes", 1, 1, NULL, 0 },
        { "No",  0, 1, NULL, 0 },
    };
    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, 3, &label);
    return id == 1;
}

static char *expand_home_alloc(const char *path, char *out, size_t outlen) {
    if (path[0] == '~') {
        const char *home = getenv("HOME");
        if (!home || !home[0]) home = "/";
        snprintf(out, outlen, "%s%s", home, path + 1);
    } else {
        snprintf(out, outlen, "%s", path);
    }
    return out;
}

static void sanitize_leaf(const char *in, char *out, size_t outlen) {
    size_t o = 0;
    for (const char *p = in; *p && o + 1 < outlen; p++) {
        unsigned char c = (unsigned char)*p;
        out[o++] = (isalnum(c) || c == '.' || c == '_' || c == '-') ? (char)c : '-';
    }
    if (o == 0 && outlen > 8) { snprintf(out, outlen, "disk"); return; }
    out[o] = '\0';
}

static void mkdir_recursive(const char *path) {
    char tmp[1024];
    snprintf(tmp, sizeof(tmp), "%s", path);
    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            mkdir(tmp, 0755);
            *p = '/';
        }
    }
    mkdir(tmp, 0755);
}

static void spawn_argv(char *const argv[]) {
    pid_t pid = fork();
    if (pid == 0) {
        setsid();
        execvp(argv[0], argv);
        _exit(127);
    }
}

static int split_ws(char *s, char *argv[], int max) {
    int n = 0;
    char *tok = strtok(s, " \t");
    while (tok && n < max - 1) { argv[n++] = tok; tok = strtok(NULL, " \t"); }
    argv[n] = NULL;
    return n;
}

static void run_custom_entry(const char *tmpl, const Device *d) {
    char buf[2048];
    render_substitute_raw(tmpl, d, buf, sizeof(buf));
    char *argv[32];
    if (split_ws(buf, argv, 32) > 0) spawn_argv(argv);
}

static void launch_file_manager(const Device *d) {
    char tmpl[512];
    snprintf(tmpl, sizeof(tmpl), "%s", FILE_MANAGER_CMD);
    char *sp = strchr(tmpl, ' ');
    char *rest = NULL;
    if (sp) { *sp = '\0'; rest = sp + 1; }
    char arg[1024] = "";
    if (rest) render_substitute_raw(rest, d, arg, sizeof(arg));
    char *argv[3];
    int i = 0;
    argv[i++] = tmpl;
    if (arg[0]) argv[i++] = arg;
    argv[i] = NULL;
    spawn_argv(argv);
}

void action_signal_daemon_reload(void) {
    pid_t pid = load_daemon_pid();
    if (pid > 0) kill(pid, SIGUSR1);
}

/* ------------------------------------------------------------------ */
/* clipboard                                                            */
/* ------------------------------------------------------------------ */

static void copy_to_clipboard(Display *dpy, const char *text) {
    if (CLIPBOARD_EXTERNAL_CMD[0]) {
        FILE *p = popen(CLIPBOARD_EXTERNAL_CMD, "w");
        if (p) { fputs(text, p); pclose(p); }
        return;
    }

    int screen = DefaultScreen(dpy);
    Window win = XCreateSimpleWindow(dpy, RootWindow(dpy, screen), 0, 0, 1, 1, 0, 0, 0);
    Atom clipboard = XInternAtom(dpy, "CLIPBOARD", False);
    Atom utf8 = XInternAtom(dpy, "UTF8_STRING", False);
    Atom targets_atom = XInternAtom(dpy, "TARGETS", False);

    static char held[2048];
    snprintf(held, sizeof(held), "%s", text);

    XSetSelectionOwner(dpy, XA_PRIMARY, win, CurrentTime);
    XSetSelectionOwner(dpy, clipboard, win, CurrentTime);

    time_t start = time(NULL);
    while (time(NULL) - start < CLIPBOARD_HOLD_SECONDS) {
        while (XPending(dpy)) {
            XEvent ev;
            XNextEvent(dpy, &ev);
            if (ev.type == SelectionRequest) {
                XSelectionRequestEvent *req = &ev.xselectionrequest;
                XSelectionEvent resp;
                resp.type = SelectionNotify;
                resp.display = req->display;
                resp.requestor = req->requestor;
                resp.selection = req->selection;
                resp.target = req->target;
                resp.time = req->time;
                resp.property = None;

                if (req->target == targets_atom) {
                    Atom types[2] = { utf8, XA_STRING };
                    XChangeProperty(dpy, req->requestor, req->property, XA_ATOM, 32,
                                    PropModeReplace, (unsigned char *)types, 2);
                    resp.property = req->property;
                } else if (req->target == utf8 || req->target == XA_STRING) {
                    XChangeProperty(dpy, req->requestor, req->property, req->target, 8,
                                    PropModeReplace, (unsigned char *)held, (int)strlen(held));
                    resp.property = req->property;
                }
                XSendEvent(dpy, req->requestor, False, 0, (XEvent *)&resp);
            } else if (ev.type == SelectionClear) {
                XDestroyWindow(dpy, win);
                return;
            }
        }
        struct timeval tv = { 0, 100000 };
        int fd = ConnectionNumber(dpy);
        fd_set fds; FD_ZERO(&fds); FD_SET(fd, &fds);
        select(fd + 1, &fds, NULL, NULL, &tv);
    }
    XDestroyWindow(dpy, win);
}

/* ------------------------------------------------------------------ */
/* core actions (shared by menu dispatch + daemon automount)           */
/* ------------------------------------------------------------------ */

int action_perform_mount(Device *d, char **out_mount_point) {
    char *mp = NULL, *err = NULL;
    int ok = udisks_mount(d->object_path, &mp, &err);

    if (ok) {
        free(d->mount_point);
        d->mount_point = mp ? strdup(mp) : NULL;
        d->is_mounted = 1;

        char body[600];
        snprintf(body, sizeof(body), "%s mounted at %s", d->display_name, d->mount_point ? d->mount_point : "?");
        if (NOTIFY_ON_MOUNT_SUCCESS) ud_notify("Disk Mounted", body);

#if ENABLE_MOUNT_POINT_SYMLINKS
        if (d->uuid[0] && d->mount_point) {
            char *sl = state_get_symlink(d->uuid);
            if (sl) {
                unlink(sl);
                if (symlink(d->mount_point, sl) == 0) {
                    free(d->symlink_path);
                    d->symlink_path = sl;
                } else {
                    free(sl);
                }
            }
        }
#endif
        if (out_mount_point) *out_mount_point = d->mount_point ? strdup(d->mount_point) : NULL;
    } else {
        if (NOTIFY_ON_MOUNT_FAILURE) {
            char body[600];
            snprintf(body, sizeof(body), "%s: %s", d->display_name, err ? err : "unknown error");
            ud_notify("Mount Failed", body);
        }
        if (out_mount_point) *out_mount_point = NULL;
    }
    free(mp);
    free(err);
    return ok;
}

int action_perform_unmount(Device *d, int force) {
    if (d->symlink_path) {
        unlink(d->symlink_path);
        free(d->symlink_path);
        d->symlink_path = NULL;
    }

    char *err = NULL;
    int ok = udisks_unmount(d->object_path, force, &err);

    if (ok) {
        free(d->mount_point);
        d->mount_point = NULL;
        d->is_mounted = 0;
        d->usage_valid = 0;
        if (NOTIFY_ON_UNMOUNT_SUCCESS) {
            char body[300];
            snprintf(body, sizeof(body), "%s unmounted", d->display_name);
            ud_notify("Disk Unmounted", body);
        }
    } else {
        if (NOTIFY_ON_UNMOUNT_FAILURE) {
            char body[600];
            snprintf(body, sizeof(body), "%s: %s", d->display_name, err ? err : "unknown error");
            ud_notify("Unmount Failed", body);
        }
    }
    free(err);
    return ok;
}

int action_perform_eject(Device *d) {
    if (!d->drive_object_path) return 0;
    char *err = NULL;
    int ok = udisks_eject(d->drive_object_path, &err);
    if (ok) {
        if (NOTIFY_ON_EJECT) ud_notify("Ejected", d->display_name);
    } else if (NOTIFY_ON_EJECT) {
        char body[600];
        snprintf(body, sizeof(body), "%s: %s", d->display_name, err ? err : "unknown error");
        ud_notify("Eject Failed", body);
    }
    free(err);
    return ok;
}

int action_perform_power_off(Device *d) {
    if (!d->drive_object_path) return 0;
    char *err = NULL;
    int ok = udisks_power_off(d->drive_object_path, &err);
    if (ok) {
        if (NOTIFY_ON_POWER_OFF) ud_notify("Powered Off", d->display_name);
    } else if (NOTIFY_ON_POWER_OFF) {
        char body[600];
        snprintf(body, sizeof(body), "%s: %s", d->display_name, err ? err : "unknown error");
        ud_notify("Power Off Failed", body);
    }
    free(err);
    return ok;
}

/* ------------------------------------------------------------------ */
/* change mount point                                                   */
/* ------------------------------------------------------------------ */

static void change_mount_point(Display *dpy, int x, int y, Device *d) {
    if (!d->is_mounted || !d->mount_point) return;

    char leaf[256];
    sanitize_leaf(d->display_name, leaf, sizeof(leaf));
    char parent[1024];
    expand_home_alloc(SYMLINK_DEFAULT_PARENT_DIR, parent, sizeof(parent));
    char default_path[1300];
    snprintf(default_path, sizeof(default_path), "%s/%s", parent, leaf);

    char *typed = xinput_show(dpy, x, y, "Symlink path (Enter=confirm, Esc=cancel):", default_path);
    if (!typed || !typed[0]) { free(typed); return; }

    char expanded[1300];
    expand_home_alloc(typed, expanded, sizeof(expanded));
    free(typed);

    struct stat st;
    if (lstat(expanded, &st) == 0) {
        if (!S_ISLNK(st.st_mode)) {
            ud_notify("Change Mount Point", "That path already exists and isn't a symlink -- refusing to overwrite it.");
            return;
        }
        unlink(expanded);
    }

    char parent_dir[1300];
    snprintf(parent_dir, sizeof(parent_dir), "%s", expanded);
    char *slash = strrchr(parent_dir, '/');
    if (slash && slash != parent_dir) { *slash = '\0'; mkdir_recursive(parent_dir); }

    if (symlink(d->mount_point, expanded) != 0) {
        char msg[1400];
        snprintf(msg, sizeof(msg), "Could not create symlink: %s", strerror(errno));
        ud_notify("Change Mount Point", msg);
        return;
    }

    if (d->uuid[0]) state_set_symlink(d->uuid, expanded);
    free(d->symlink_path);
    d->symlink_path = strdup(expanded);

    char msg[1400];
    snprintf(msg, sizeof(msg), "%s -> %s", expanded, d->mount_point);
    ud_notify("Mount Point Linked", msg);
}

static void remove_mount_point(Device *d) {
    if (!d->symlink_path) return;
    unlink(d->symlink_path);
    if (d->uuid[0]) state_set_symlink(d->uuid, NULL);
    free(d->symlink_path);
    d->symlink_path = NULL;
    ud_notify("Mount Point Unlinked", "Custom mount-point symlink removed.");
}

/* ------------------------------------------------------------------ */
/* device menu                                                          */
/* ------------------------------------------------------------------ */

void action_open_device_menu(Display *dpy, int x, int y, Device *d, DeviceList *list) {
    (void)list;
    save_last_device(d->object_path);

    MenuItem items[64];
    int n = 0;

    char pool[20][600];
    int pn = 0;
#define BUF() pool[pn++]

    add_info(items, &n, d->display_name);

    if (MENU_SHOW_DEVICE_NODE) {
        char *b = BUF(); snprintf(b, 600, "Device: %s", d->device_node);
        add_info(items, &n, b);
    }
    if (MENU_SHOW_UUID && d->uuid[0]) {
        char *b = BUF(); snprintf(b, 600, "UUID: %s", d->uuid);
        add_info(items, &n, b);
    }
    if (MENU_SHOW_FILESYSTEM_TYPE && d->fs_type[0]) {
        char *b = BUF(); snprintf(b, 600, "Filesystem: %s%s", d->fs_type, d->read_only ? " (read-only)" : "");
        add_info(items, &n, b);
    }
    if (MENU_SHOW_DRIVE_MODEL && (d->drive_vendor[0] || d->drive_model[0])) {
        char *b = BUF(); snprintf(b, 600, "Drive: %s %s", d->drive_vendor, d->drive_model);
        add_info(items, &n, b);
    }
    if (MENU_SHOW_CONNECTION_BUS && d->connection_bus[0]) {
        char *b = BUF(); snprintf(b, 600, "Bus: %s", d->connection_bus);
        add_info(items, &n, b);
    }

    if (d->is_mounted) {
        if (d->symlink_path && MENU_SHOW_SYMLINK_TARGET) {
            char *b1 = BUF(); snprintf(b1, 600, "Link: %s", d->symlink_path);
            add_info(items, &n, b1);
            char *b2 = BUF(); snprintf(b2, 600, "Mount: %s", d->mount_point);
            add_info(items, &n, b2);
        } else if (MENU_SHOW_MOUNT_POINT) {
            char *b = BUF(); snprintf(b, 600, "Mount: %s", d->mount_point);
            add_info(items, &n, b);
        }

        if (d->usage_valid) {
            char sz[16];
            if (MENU_SHOW_USED) {
                device_format_size(d->used_bytes, sz, sizeof(sz));
                char *b = BUF(); snprintf(b, 600, "Used: %s", sz);
                add_info(items, &n, b);
            }
            if (MENU_SHOW_FREE) {
                device_format_size(d->free_bytes, sz, sizeof(sz));
                char *b = BUF(); snprintf(b, 600, "Free: %s", sz);
                add_info(items, &n, b);
            }
            if (MENU_SHOW_TOTAL) {
                device_format_size(d->total_bytes, sz, sizeof(sz));
                char *b = BUF(); snprintf(b, 600, "Total: %s", sz);
                add_info(items, &n, b);
            }
            if (MENU_SHOW_PERCENT_USED) {
                char *b = BUF(); snprintf(b, 600, "Used: %d%%", d->percent_used);
                add_info(items, &n, b);
            }
        }
    } else {
        char *b = BUF(); snprintf(b, 600, "Not mounted");
        add_info(items, &n, b);
    }

    add_sep(items, &n);

    if (!d->is_mounted && MENU_ACTION_MOUNT)
        add_action(items, &n, "Mount", ACT_MOUNT, 1);

    if (d->is_mounted && !d->is_protected && MENU_ACTION_UNMOUNT)
        add_action(items, &n, "Unmount", ACT_UNMOUNT, 1);

    if (d->is_mounted && MENU_ACTION_OPEN_FILE_MANAGER)
        add_action(items, &n, "Open in File Manager", ACT_OPEN_FILE_MANAGER, 1);

    if (d->is_mounted && MENU_ACTION_COPY_MOUNT_PATH)
        add_action(items, &n, "Copy Mount Path", ACT_COPY_MOUNT_PATH, 1);

#if ENABLE_MOUNT_POINT_SYMLINKS
    if (d->is_mounted && MENU_ACTION_CHANGE_MOUNT_POINT) {
        add_action(items, &n, d->symlink_path ? "Change Mount Point..." : "Set Custom Mount Point...",
                    ACT_CHANGE_MOUNT_POINT, 1);
        if (d->symlink_path)
            add_action(items, &n, "Remove Custom Mount Point", ACT_REMOVE_MOUNT_POINT, 1);
    }
#endif

    if (!d->is_protected && MENU_ACTION_EJECT)
        add_action(items, &n, "Eject", ACT_EJECT, d->ejectable);

    if (!d->is_protected && MENU_ACTION_POWER_OFF)
        add_action(items, &n, "Power Off (Safely Remove)", ACT_POWER_OFF, d->can_power_off);

    if (MENU_ACTION_RELOAD)
        add_action(items, &n, "Reload", ACT_RELOAD, 1);

#if MENU_SHOW_CUSTOM_ENTRIES
    if (CUSTOM_DEVICE_MENU_ENTRIES[0].command_template) add_sep(items, &n);
    for (int i = 0; CUSTOM_DEVICE_MENU_ENTRIES[i].command_template; i++)
        add_action(items, &n, CUSTOM_DEVICE_MENU_ENTRIES[i].label, ACT_CUSTOM_BASE + i, 1);
#endif

    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, n, &label);
    if (id < 0) return;

    switch (id) {
        case ACT_MOUNT:
            action_perform_mount(d, NULL);
            break;
        case ACT_UNMOUNT: {
            int go = 1;
            if (CONFIRM_UNMOUNT) {
                char q[300]; snprintf(q, sizeof(q), "Unmount %s?", d->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (go && !action_perform_unmount(d, 0)) {
                char q[300]; snprintf(q, sizeof(q), "%s is busy. Force unmount anyway?", d->display_name);
                if (confirm_dialog(dpy, x, y, q)) action_perform_unmount(d, 1);
            }
            break;
        }
        case ACT_EJECT: {
            int go = 1;
            if (CONFIRM_EJECT) {
                char q[300]; snprintf(q, sizeof(q), "Eject %s?", d->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (go) action_perform_eject(d);
            break;
        }
        case ACT_POWER_OFF: {
            int go = 1;
            if (CONFIRM_POWER_OFF) {
                char q[300]; snprintf(q, sizeof(q), "Power off %s? This cuts power to the port.", d->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (go) action_perform_power_off(d);
            break;
        }
        case ACT_OPEN_FILE_MANAGER:
            launch_file_manager(d);
            break;
        case ACT_CHANGE_MOUNT_POINT:
            change_mount_point(dpy, x, y, d);
            break;
        case ACT_REMOVE_MOUNT_POINT:
            remove_mount_point(d);
            break;
        case ACT_COPY_MOUNT_PATH:
            if (d->mount_point) copy_to_clipboard(dpy, d->mount_point);
            break;
        case ACT_RELOAD:
            action_signal_daemon_reload();
            break;
        default:
            if (id >= ACT_CUSTOM_BASE && id < ACT_CUSTOM_BASE + 900) {
                int i = id - ACT_CUSTOM_BASE;
                if (CUSTOM_DEVICE_MENU_ENTRIES[i].command_template)
                    run_custom_entry(CUSTOM_DEVICE_MENU_ENTRIES[i].command_template, d);
            }
            break;
    }
#undef BUF
}

/* ------------------------------------------------------------------ */
/* generic (non-device) menu                                            */
/* ------------------------------------------------------------------ */

static void mount_iso(Display *dpy, int x, int y) {
    int count = 0;
    char **paths = filepicker_choose(dpy, x, y, 0, &count);
    if (count != 1 || !paths) {
        for (int i = 0; i < count; i++) free(paths[i]);
        free(paths);
        return;
    }

    char *block_path = NULL, *mount_point = NULL, *err = NULL;
    int ok = udisks_loop_mount_file(paths[0], &block_path, &mount_point, &err);

    if (ok && NOTIFY_ON_MOUNT_SUCCESS) {
        char body[900];
        snprintf(body, sizeof(body), "%s mounted at %s", paths[0], mount_point ? mount_point : "?");
        ud_notify("ISO Mounted", body);
    } else if (!ok && NOTIFY_ON_MOUNT_FAILURE) {
        char body[900];
        snprintf(body, sizeof(body), "%s: %s", paths[0], err ? err : "unknown error");
        ud_notify("Mount ISO Failed", body);
    }

    free(block_path);
    free(mount_point);
    free(err);
    for (int i = 0; i < count; i++) free(paths[i]);
    free(paths);
}

static void detach_isos_menu(Display *dpy, int x, int y) {
    UdisksRawObject *raw = NULL;
    int n_raw = udisks_get_all(&raw);
    if (n_raw <= 0) { udisks_free_raw_objects(raw, n_raw > 0 ? n_raw : 0); return; }

    MenuItem items[32];
    int n = 0;
    char *loop_paths[32];
    int n_loops = 0;
    char labels[32][600];

    for (int i = 0; i < n_raw && n_loops < 32; i++) {
        if (!raw[i].has_loop) continue;
        const char *file = raw[i].loop_backing_file ? raw[i].loop_backing_file : "(unknown file)";
        const char *base = strrchr(file, '/');
        base = base ? base + 1 : file;
        snprintf(labels[n_loops], sizeof(labels[n_loops]), "Detach: %s%s", base,
                 (raw[i].n_mount_points > 0) ? "" : " (unmounted)");
        loop_paths[n_loops] = strdup(raw[i].path);
        add_action(items, &n, labels[n_loops], ACT_GENERIC_DETACH_BASE + n_loops, 1);
        n_loops++;
    }

    if (n_loops == 0) {
        udisks_free_raw_objects(raw, n_raw);
        return;
    }

    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, n, &label);
    if (id >= ACT_GENERIC_DETACH_BASE && id < ACT_GENERIC_DETACH_BASE + n_loops) {
        int idx = id - ACT_GENERIC_DETACH_BASE;
        char *err = NULL;
        int ok = udisks_loop_delete(loop_paths[idx], &err);
        if (!ok && NOTIFY_ON_UNMOUNT_FAILURE) ud_notify("Detach Failed", err ? err : "unknown error");
        free(err);
    }

    for (int i = 0; i < n_loops; i++) free(loop_paths[i]);
    udisks_free_raw_objects(raw, n_raw);
}

void action_open_generic_menu(Display *dpy, int x, int y, DeviceList *list) {
    (void)list;
    MenuItem items[32];
    int n = 0;

    if (GENERIC_MENU_SHOW_MOUNT_ISO) add_action(items, &n, "Mount ISO / Image...", ACT_GENERIC_MOUNT_ISO, 1);

    int have_loops = 0;
    if (GENERIC_MENU_SHOW_UNMOUNT_ISOS) {
        UdisksRawObject *raw = NULL;
        int n_raw = udisks_get_all(&raw);
        for (int i = 0; i < n_raw; i++) if (raw[i].has_loop) have_loops = 1;
        udisks_free_raw_objects(raw, n_raw > 0 ? n_raw : 0);
        if (have_loops) add_action(items, &n, "Detach ISO...", ACT_GENERIC_DETACH_BASE - 1, 1);
    }

    if (GENERIC_MENU_SHOW_DISK_UTILITY) add_action(items, &n, "Open Disk Utility", ACT_GENERIC_DISK_UTILITY, 1);
    if (GENERIC_MENU_SHOW_RELOAD_ALL) add_action(items, &n, "Reload", ACT_GENERIC_RELOAD_ALL, 1);

#if GENERIC_MENU_SHOW_CUSTOM_ENTRIES
    if (CUSTOM_GENERIC_MENU_ENTRIES[0].command_template) add_sep(items, &n);
    for (int i = 0; CUSTOM_GENERIC_MENU_ENTRIES[i].command_template; i++)
        add_action(items, &n, CUSTOM_GENERIC_MENU_ENTRIES[i].label, ACT_GENERIC_CUSTOM_BASE + i, 1);
#endif

    if (n == 0) return;

    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, n, &label);
    if (id < 0) return;

    if (id == ACT_GENERIC_MOUNT_ISO) {
        mount_iso(dpy, x, y);
    } else if (id == ACT_GENERIC_DETACH_BASE - 1) {
        detach_isos_menu(dpy, x, y);
    } else if (id == ACT_GENERIC_DISK_UTILITY) {
        char *argv[2] = { (char *)DISK_UTILITY_CMD, NULL };
        spawn_argv(argv);
    } else if (id == ACT_GENERIC_RELOAD_ALL) {
        action_signal_daemon_reload();
    } else if (id >= ACT_GENERIC_CUSTOM_BASE && id < ACT_GENERIC_CUSTOM_BASE + 900) {
        int i = id - ACT_GENERIC_CUSTOM_BASE;
        if (CUSTOM_GENERIC_MENU_ENTRIES[i].command_template)
            run_custom_entry(CUSTOM_GENERIC_MENU_ENTRIES[i].command_template, NULL);
    }
}
