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
#include "passphrase_cache.h"
#include "mtp_transfer.h"
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
    ACT_UNLOCK,
    ACT_LOCK,
    ACT_FORGET_PASSPHRASE,
    ACT_CUSTOM_BASE      = 1000,

    ACT_GENERIC_MOUNT_ISO   = 2000,
    ACT_GENERIC_DISK_UTILITY,
    ACT_GENERIC_RELOAD_ALL,
    ACT_GENERIC_DETACH_BASE = 3000,
    ACT_GENERIC_CUSTOM_BASE = 4000,

    ACT_MTP_MOUNT = 5000,
    ACT_MTP_UNMOUNT,
    ACT_MTP_OPEN_FILE_MANAGER,
    ACT_MTP_COPY_MOUNT_PATH,
    ACT_MTP_RELOAD,
    ACT_MTP_DOWNLOAD,
    ACT_MTP_UPLOAD,
    ACT_MTP_SCRCPY_TOGGLE,
    ACT_MTP_CUSTOM_BASE = 6000,
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
/* LUKS unlock / lock                                                   */
/* ------------------------------------------------------------------ */

void action_unlock_device(Display *dpy, int x, int y, Device *d) {
    if (!d->is_locked) return;

    int remember = device_should_remember_passphrase(d);
    char *passphrase = NULL;
    int from_cache = 0;

    if (remember && d->uuid[0]) {
        passphrase = passphrase_cache_get(d->uuid);
        if (passphrase) from_cache = 1;
    }

    if (!passphrase) {
        char prompt[300];
        snprintf(prompt, sizeof(prompt), "Passphrase for %s:", d->display_name);
        passphrase = xinput_show(dpy, x, y, prompt, "", 1 /* mask */);
        if (!passphrase) return; /* cancelled */
    }

    char *cleartext_path = NULL, *err = NULL;
    int ok = udisks_unlock(d->object_path, passphrase, &cleartext_path, &err);

    if (ok) {
        if (NOTIFY_ON_UNLOCK_SUCCESS) ud_notify("Unlocked", d->display_name);
        if (remember && d->uuid[0]) passphrase_cache_set(d->uuid, passphrase);

        if (cleartext_path) {
            char *mp = NULL, *mount_err = NULL;
            int mounted = udisks_mount(cleartext_path, &mp, &mount_err);
            if (mounted) {
                if (NOTIFY_ON_MOUNT_SUCCESS) {
                    char body[600];
                    snprintf(body, sizeof(body), "%s mounted at %s", d->display_name, mp ? mp : "?");
                    ud_notify("Disk Mounted", body);
                }
            } else if (NOTIFY_ON_MOUNT_FAILURE) {
                char body[600];
                snprintf(body, sizeof(body), "%s: %s", d->display_name, mount_err ? mount_err : "unknown error");
                ud_notify("Mount Failed", body);
            }
            free(mp);
            free(mount_err);
        }
    } else {
        if (NOTIFY_ON_UNLOCK_FAILURE) {
            char body[600];
            snprintf(body, sizeof(body), "%s: %s", d->display_name,
                     err ? err : (from_cache ? "cached passphrase was rejected" : "unknown error"));
            ud_notify("Unlock Failed", body);
        }
        if (from_cache && d->uuid[0]) passphrase_cache_forget(d->uuid); /* stale/wrong -- don't keep offering it */
    }

    free(cleartext_path);
    free(err);
    passphrase_cache_wipe(passphrase);
}

void action_lock_device(Display *dpy, int x, int y, Device *d) {
    if (!d->parent_luks_path) return;

    if (CONFIRM_LOCK) {
        char q[300]; snprintf(q, sizeof(q), "Lock %s?", d->display_name);
        if (!confirm_dialog(dpy, x, y, q)) return;
    }

    if (d->is_mounted) {
        if (!action_perform_unmount(d, 0)) return; /* leave it alone if still busy -- don't force-lock over open files */
    }

    char *err = NULL;
    int ok = udisks_lock(d->parent_luks_path, &err);
    if (ok) {
        if (NOTIFY_ON_LOCK) ud_notify("Locked", d->display_name);
    } else if (NOTIFY_ON_LOCK) {
        char body[600];
        snprintf(body, sizeof(body), "%s: %s", d->display_name, err ? err : "unknown error");
        ud_notify("Lock Failed", body);
    }
    free(err);
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

    char *typed = xinput_show(dpy, x, y, "Symlink path (Enter=confirm, Esc=cancel):", default_path, 0);
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

/* Eject/Power Off act on the whole drive, not just `d` -- fails with
 * "busy" if any sibling partition on the same drive is still
 * mounted, `d` itself included. Per EJECT_POWEROFF_UNMOUNT_MODE,
 * either does nothing extra (old behavior), prompts once and unmounts
 * everything still mounted on the drive, or does that silently.
 * Returns 1 to proceed with Eject/Power Off, 0 to abort (declined the
 * prompt, or a required unmount failed). */
static int ensure_drive_unmounted(Display *dpy, int x, int y, Device *d, DeviceList *list, const char *verb) {
#if EJECT_POWEROFF_UNMOUNT_MODE == EJECT_POWEROFF_UNMOUNT_NONE
    (void)dpy; (void)x; (void)y; (void)d; (void)list; (void)verb;
    return 1;
#else
    if (!list || !d->drive_object_path) return 1;

    Device *mounted[32];
    int n_mounted = 0;
    for (int i = 0; i < list->count && n_mounted < 32; i++) {
        Device *cand = &list->items[i];
        if (!cand->drive_object_path) continue;
        if (strcmp(cand->drive_object_path, d->drive_object_path) != 0) continue;
        if (cand->is_mounted) mounted[n_mounted++] = cand;
    }
    if (n_mounted == 0) return 1;

#if EJECT_POWEROFF_UNMOUNT_MODE == EJECT_POWEROFF_UNMOUNT_PROMPT
    char q[400];
    if (n_mounted == 1) {
        snprintf(q, sizeof(q), "%s is still mounted. Unmount it and %s?", mounted[0]->display_name, verb);
    } else {
        snprintf(q, sizeof(q), "%d partitions on this drive are still mounted. Unmount them and %s?",
                 n_mounted, verb);
    }
    if (!confirm_dialog(dpy, x, y, q)) return 0;
#endif

    int all_ok = 1;
    for (int i = 0; i < n_mounted; i++) {
        if (!action_perform_unmount(mounted[i], 0)) all_ok = 0;
    }
    return all_ok;
#endif
}

void action_open_device_menu(Display *dpy, int x, int y, Device *d, DeviceList *list) {
    save_last_device(d->object_path);

#if ENABLE_LUKS
    if (d->is_locked) {
        MenuItem litems[8];
        int ln = 0;
        char lb1[600], lb2[600];
        add_info(litems, &ln, d->display_name);
        if (MENU_SHOW_DEVICE_NODE) {
            snprintf(lb1, sizeof(lb1), "Device: %s", d->device_node);
            add_info(litems, &ln, lb1);
        }
        snprintf(lb2, sizeof(lb2), "Locked (LUKS)");
        add_info(litems, &ln, lb2);
        add_sep(litems, &ln);
        if (MENU_ACTION_UNLOCK) add_action(litems, &ln, "Unlock...", ACT_UNLOCK, 1);
        add_action(litems, &ln, "Forget Cached Passphrase", ACT_FORGET_PASSPHRASE, 1);

        const char *llabel = NULL;
        int lid = xmenu_show(dpy, x, y, litems, ln, &llabel);
        if (lid == ACT_UNLOCK) {
            action_unlock_device(dpy, x, y, d);
        } else if (lid == ACT_FORGET_PASSPHRASE) {
            if (d->uuid[0]) passphrase_cache_forget(d->uuid);
            ud_notify("Passphrase Forgotten", d->display_name);
        }
        return;
    }
#endif

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

#if ENABLE_LUKS
    if (d->is_encrypted && d->parent_luks_path && MENU_ACTION_LOCK)
        add_action(items, &n, "Lock", ACT_LOCK, 1);
    if (d->is_encrypted && d->parent_luks_uuid && d->parent_luks_uuid[0])
        add_action(items, &n, "Forget Cached Passphrase", ACT_FORGET_PASSPHRASE, 1);
#endif

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
            int go = ensure_drive_unmounted(dpy, x, y, d, list, "eject");
            if (go && CONFIRM_EJECT) {
                char q[300]; snprintf(q, sizeof(q), "Eject %s?", d->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (go) action_perform_eject(d);
            break;
        }
        case ACT_POWER_OFF: {
            int go = ensure_drive_unmounted(dpy, x, y, d, list, "power off");
            if (go && CONFIRM_POWER_OFF) {
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
        case ACT_LOCK:
            action_lock_device(dpy, x, y, d);
            break;
        case ACT_FORGET_PASSPHRASE:
            if (d->parent_luks_uuid && d->parent_luks_uuid[0]) passphrase_cache_forget(d->parent_luks_uuid);
            ud_notify("Passphrase Forgotten", d->display_name);
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

    if (block_path) state_mark_iso_loop(block_path); /* even on partial failure -- see udisks_loop_mount_file: the loop device may still have been created and attached even if mounting its filesystem then failed, and it should still be reachable/detachable */

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

        /* Mounted state: check the loop device itself, and (for
         * hybrid/bootable ISOs) any partition of it too -- see
         * udisks_loop_mount_file's comment on why the filesystem
         * doesn't always end up directly on the loop device. */
        int mounted = raw[i].n_mount_points > 0;
        if (!mounted) {
            for (int j = 0; j < n_raw; j++) {
                if (raw[j].partition_table_path && !strcmp(raw[j].partition_table_path, raw[i].path) &&
                    raw[j].n_mount_points > 0) {
                    mounted = 1;
                    break;
                }
            }
        }

        snprintf(labels[n_loops], sizeof(labels[n_loops]), "Detach: %s%s", base,
                 mounted ? "" : " (unmounted)");
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
        if (ok) state_unmark_iso_loop(loop_paths[idx]);
        if (!ok && NOTIFY_ON_UNMOUNT_FAILURE) ud_notify("Detach Failed", err ? err : "unknown error");
        free(err);
    }

    for (int i = 0; i < n_loops; i++) free(loop_paths[i]);
    udisks_free_raw_objects(raw, n_raw);
}

/* ------------------------------------------------------------------ */
/* iso (mounted image) menu                                             */
/* ------------------------------------------------------------------ */

enum { ACT_ISO_OPEN_FILE_MANAGER = 7000, ACT_ISO_COPY_MOUNT_PATH, ACT_ISO_DETACH, ACT_ISO_RELOAD, ACT_ISO_CUSTOM_BASE = 7100 };

void action_open_iso_menu(Display *dpy, int x, int y, Device *d) {
    MenuItem items[32];
    int n = 0;
    char pool[8][700];
    int pn = 0;
#define IBUF() pool[pn++]

    add_info(items, &n, d->display_name);
    if (MENU_SHOW_ISO_BACKING_FILE && d->loop_backing_file && d->loop_backing_file[0]) {
        char *b = IBUF(); snprintf(b, 700, "File: %s", d->loop_backing_file);
        add_info(items, &n, b);
    }
    if (d->is_mounted) {
        if (MENU_SHOW_ISO_MOUNT_POINT) {
            char *b = IBUF(); snprintf(b, 700, "Mount: %s", d->mount_point ? d->mount_point : "?");
            add_info(items, &n, b);
        }
        if (d->usage_valid) {
            char sz[16];
            if (MENU_SHOW_ISO_USED) {
                device_format_size(d->used_bytes, sz, sizeof(sz));
                char *b = IBUF(); snprintf(b, 700, "Used: %s", sz);
                add_info(items, &n, b);
            }
            if (MENU_SHOW_ISO_FREE) {
                device_format_size(d->free_bytes, sz, sizeof(sz));
                char *b = IBUF(); snprintf(b, 700, "Free: %s", sz);
                add_info(items, &n, b);
            }
            if (MENU_SHOW_ISO_TOTAL) {
                device_format_size(d->total_bytes, sz, sizeof(sz));
                char *b = IBUF(); snprintf(b, 700, "Total: %s", sz);
                add_info(items, &n, b);
            }
        }
    } else {
        char *b = IBUF(); snprintf(b, 700, "Not mounted");
        add_info(items, &n, b);
    }

    add_sep(items, &n);

    if (d->is_mounted && MENU_ACTION_ISO_OPEN_FILE_MANAGER)
        add_action(items, &n, "Open in File Manager", ACT_ISO_OPEN_FILE_MANAGER, 1);
    if (d->is_mounted && MENU_ACTION_ISO_COPY_MOUNT_PATH)
        add_action(items, &n, "Copy Mount Path", ACT_ISO_COPY_MOUNT_PATH, 1);
    if (MENU_ACTION_ISO_DETACH)
        add_action(items, &n, "Detach", ACT_ISO_DETACH, 1);
    if (MENU_ACTION_ISO_RELOAD)
        add_action(items, &n, "Reload", ACT_ISO_RELOAD, 1);

    if (CUSTOM_ISO_MENU_ENTRIES[0].command_template) add_sep(items, &n);
    for (int i = 0; CUSTOM_ISO_MENU_ENTRIES[i].command_template; i++)
        add_action(items, &n, CUSTOM_ISO_MENU_ENTRIES[i].label, ACT_ISO_CUSTOM_BASE + i, 1);

    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, n, &label);
    if (id < 0) return;

    switch (id) {
        case ACT_ISO_OPEN_FILE_MANAGER:
            launch_file_manager(d);
            break;
        case ACT_ISO_COPY_MOUNT_PATH:
            if (d->mount_point) copy_to_clipboard(dpy, d->mount_point);
            break;
        case ACT_ISO_DETACH: {
            int go = 1;
            if (CONFIRM_ISO_DETACH) {
                char q[400]; snprintf(q, sizeof(q), "Detach %s?", d->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (go) {
                char *err = NULL;
                int ok = udisks_loop_delete(d->object_path, &err);
                if (ok) {
                    state_unmark_iso_loop(d->object_path);
                    if (NOTIFY_ON_UNMOUNT_SUCCESS) ud_notify("ISO Detached", d->display_name);
                } else if (NOTIFY_ON_UNMOUNT_FAILURE) {
                    char body[900]; snprintf(body, sizeof(body), "%s: %s", d->display_name, err ? err : "unknown error");
                    ud_notify("Detach Failed", body);
                }
                free(err);
            }
            break;
        }
        case ACT_ISO_RELOAD:
            action_signal_daemon_reload();
            break;
        default:
            if (id >= ACT_ISO_CUSTOM_BASE && id < ACT_ISO_CUSTOM_BASE + 900) {
                int i = id - ACT_ISO_CUSTOM_BASE;
                if (CUSTOM_ISO_MENU_ENTRIES[i].command_template)
                    run_custom_entry(CUSTOM_ISO_MENU_ENTRIES[i].command_template, d);
            }
            break;
    }
#undef IBUF
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

/* ------------------------------------------------------------------ */
/* mtp (phone) menu                                                     */
/* ------------------------------------------------------------------ */

static void mtp_substitute_raw(const char *tmpl, const MtpDevice *m, char *out, size_t outlen) {
    out[0] = '\0';
    size_t o = 0;
    for (const char *p = tmpl; *p && o < outlen - 1; ) {
        const char *rep = NULL;
        size_t skip = 0;
        if (!strncmp(p, "{NAME}", 6)) { rep = m->display_name; skip = 6; }
        else if (!strncmp(p, "{MOUNTPOINT}", 12)) { rep = m->mount_point ? m->mount_point : ""; skip = 12; }
        else if (!strncmp(p, "{SELF}", 6)) { rep = render_self_path(NULL); skip = 6; }

        if (rep) {
            size_t rl = strlen(rep);
            if (o + rl >= outlen) rl = outlen - 1 - o;
            memcpy(out + o, rep, rl);
            o += rl;
            p += skip;
        } else {
            out[o++] = *p++;
        }
    }
    out[o] = '\0';
}

static void mtp_run_custom_entry(const char *tmpl, const MtpDevice *m) {
    char buf[2048];
    mtp_substitute_raw(tmpl, m, buf, sizeof(buf));
    char *argv[32];
    if (split_ws(buf, argv, 32) > 0) spawn_argv(argv);
}

static void mtp_launch_file_manager(const MtpDevice *m) {
    char tmpl[512];
    snprintf(tmpl, sizeof(tmpl), "%s", FILE_MANAGER_CMD);
    char *sp = strchr(tmpl, ' ');
    char *rest = NULL;
    if (sp) { *sp = '\0'; rest = sp + 1; }
    char arg[1024] = "";
    if (rest) mtp_substitute_raw(rest, m, arg, sizeof(arg));
    char *argv[3];
    int i = 0;
    argv[i++] = tmpl;
    if (arg[0]) argv[i++] = arg;
    argv[i] = NULL;
    spawn_argv(argv);
}

void action_open_mtp_menu(Display *dpy, int x, int y, MtpDevice *m) {
    MenuItem items[32];
    int n = 0;
    char pool[8][600];
    int pn = 0;
#define MBUF() pool[pn++]

    add_info(items, &n, m->display_name);
    if (MENU_SHOW_MTP_SERIAL && m->serial[0]) {
        char *b = MBUF(); snprintf(b, 600, "Serial: %s", m->serial);
        add_info(items, &n, b);
    }
    if (m->is_mounted) {
        char *b = MBUF(); snprintf(b, 600, "Mount: %s", m->mount_point ? m->mount_point : "?");
        add_info(items, &n, b);
        if (m->usage_valid) {
            char sz[16];
            device_format_size(m->used_bytes, sz, sizeof(sz));
            char *b1 = MBUF(); snprintf(b1, 600, "Used: %s", sz);
            add_info(items, &n, b1);
            device_format_size(m->free_bytes, sz, sizeof(sz));
            char *b2 = MBUF(); snprintf(b2, 600, "Free: %s", sz);
            add_info(items, &n, b2);
        } else {
            char *b1 = MBUF(); snprintf(b1, 600, "Usage: unavailable (this phone/MTP stack doesn't report it)");
            add_info(items, &n, b1);
        }
    } else {
        char *b = MBUF(); snprintf(b, 600, "Not mounted");
        add_info(items, &n, b);
    }
    if (m->scrcpy_pid > 0) {
        char *b = MBUF(); snprintf(b, 600, "scrcpy: running");
        add_info(items, &n, b);
    }

    add_sep(items, &n);

    if (!m->is_mounted && MENU_ACTION_MTP_MOUNT) add_action(items, &n, "Mount", ACT_MTP_MOUNT, 1);
    if (m->is_mounted && MENU_ACTION_MTP_UNMOUNT) add_action(items, &n, "Unmount", ACT_MTP_UNMOUNT, 1);
    if (m->is_mounted && MENU_ACTION_MTP_OPEN_FILE_MANAGER)
        add_action(items, &n, "Open in File Manager", ACT_MTP_OPEN_FILE_MANAGER, 1);
    if (m->is_mounted && MENU_ACTION_MTP_COPY_MOUNT_PATH)
        add_action(items, &n, "Copy Mount Path", ACT_MTP_COPY_MOUNT_PATH, 1);
    if (m->is_mounted && MENU_ACTION_MTP_DOWNLOAD)
        add_action(items, &n, "Download from Phone...", ACT_MTP_DOWNLOAD, 1);
    if (m->is_mounted && MENU_ACTION_MTP_UPLOAD)
        add_action(items, &n, "Upload to Phone...", ACT_MTP_UPLOAD, 1);
    if (MENU_ACTION_MTP_SCRCPY_TOGGLE)
        add_action(items, &n, m->scrcpy_pid > 0 ? "Stop scrcpy" : "Run scrcpy", ACT_MTP_SCRCPY_TOGGLE, 1);
    if (MENU_ACTION_MTP_RELOAD) add_action(items, &n, "Reload", ACT_MTP_RELOAD, 1);

    if (CUSTOM_MTP_MENU_ENTRIES[0].command_template) add_sep(items, &n);
    for (int i = 0; CUSTOM_MTP_MENU_ENTRIES[i].command_template; i++)
        add_action(items, &n, CUSTOM_MTP_MENU_ENTRIES[i].label, ACT_MTP_CUSTOM_BASE + i, 1);

    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, n, &label);
    if (id < 0) return;

    switch (id) {
        case ACT_MTP_MOUNT: {
            int go = 1;
            if (CONFIRM_MTP_MOUNT) {
                char q[300]; snprintf(q, sizeof(q), "Mount %s?", m->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (!go) break;
            char *err = NULL;
            int ok = mtp_perform_mount(m, &err);
            if (ok && NOTIFY_ON_MTP_MOUNT_SUCCESS) {
                char body[900]; snprintf(body, sizeof(body), "%s mounted at %s", m->display_name, m->mount_point);
                ud_notify("Phone Mounted", body);
            } else if (!ok && NOTIFY_ON_MTP_MOUNT_FAILURE) {
                char body[1400]; snprintf(body, sizeof(body), "%s: %s", m->display_name, err ? err : "unknown error");
                ud_notify("Mount Failed", body);
            }
            free(err);
            break;
        }
        case ACT_MTP_UNMOUNT: {
            int go = 1;
            if (CONFIRM_MTP_UNMOUNT) {
                char q[300]; snprintf(q, sizeof(q), "Unmount %s?", m->display_name);
                go = confirm_dialog(dpy, x, y, q);
            }
            if (!go) break;
            char *err = NULL;
            int ok = mtp_perform_unmount(m, &err);
            if (ok && NOTIFY_ON_MTP_UNMOUNT_SUCCESS) ud_notify("Phone Unmounted", m->display_name);
            else if (!ok) {
                char body[1000]; snprintf(body, sizeof(body), "%s: %s", m->display_name, err ? err : "unknown error");
                ud_notify("Unmount Failed", body);
            }
            free(err);
            break;
        }
        case ACT_MTP_OPEN_FILE_MANAGER:
            mtp_launch_file_manager(m);
            break;
        case ACT_MTP_COPY_MOUNT_PATH:
            if (m->mount_point) copy_to_clipboard(dpy, m->mount_point);
            break;
        case ACT_MTP_DOWNLOAD: {
            if (!m->mount_point) break;
            int count = 0;
            char **paths = filepicker_choose_at(dpy, x, y, m->mount_point, 1, &count);
            if (count > 0) {
                char *dest = filepicker_choose_dir_at(dpy, x, y, MTP_TRANSFER_LOCAL_DIR);
                if (dest) {
                    mtp_transfer_copy_files(dpy, x, y, paths, count, dest);
                    free(dest);
                }
            }
            for (int i = 0; i < count; i++) free(paths[i]);
            free(paths);
            break;
        }
        case ACT_MTP_UPLOAD: {
            if (!m->mount_point) break;
            int count = 0;
            char **paths = filepicker_choose_at(dpy, x, y, MTP_TRANSFER_LOCAL_DIR, 1, &count);
            if (count > 0) mtp_transfer_copy_files(dpy, x, y, paths, count, m->mount_point);
            for (int i = 0; i < count; i++) free(paths[i]);
            free(paths);
            break;
        }
        case ACT_MTP_SCRCPY_TOGGLE: {
            char *err = NULL;
            if (m->scrcpy_pid > 0) {
                mtp_scrcpy_stop(m, &err);
            } else {
                int ok = mtp_scrcpy_start(m, &err);
                if (!ok && err) {
                    char body[400]; snprintf(body, sizeof(body), "%s: %s", m->display_name, err);
                    ud_notify("scrcpy Failed", body);
                }
            }
            free(err);
            break;
        }
        case ACT_MTP_RELOAD:
            action_signal_daemon_reload();
            break;
        default:
            if (id >= ACT_MTP_CUSTOM_BASE && id < ACT_MTP_CUSTOM_BASE + 900) {
                int i = id - ACT_MTP_CUSTOM_BASE;
                if (CUSTOM_MTP_MENU_ENTRIES[i].command_template)
                    mtp_run_custom_entry(CUSTOM_MTP_MENU_ENTRIES[i].command_template, m);
            }
            break;
    }
#undef MBUF
}
