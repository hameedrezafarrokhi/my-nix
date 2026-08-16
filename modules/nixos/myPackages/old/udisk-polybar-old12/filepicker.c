/*
 * filepicker.c
 *
 * A directory browser built on the fmenu widget (search box +
 * scrollable, screen-clamped list). Each directory level is a fresh
 * fmenu_show() call; selecting a directory re-lists it, selecting a
 * file (or confirming a multi-select set) returns the path(s). No
 * external process (zenity) involved.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <dirent.h>
#include <sys/stat.h>
#include <pwd.h>
#include <unistd.h>

#include "filepicker.h"
#include "fmenu.h"
#include "config.h"

static char *expand_home(const char *path) {
    if (path[0] == '~') {
        const char *home = getenv("HOME");
        if (!home || home[0] == '\0') {
            struct passwd *pw = getpwuid(getuid());
            home = (pw && pw->pw_dir) ? pw->pw_dir : "/";
        }
        char *out = malloc(strlen(home) + strlen(path)); /* exact fit */
        if (!out) return strdup("/");
        sprintf(out, "%s%s", home, path + 1);
        return out;
    }
    return strdup(path);
}

typedef struct {
    char *name; /* raw filename, no path */
    int is_dir;
} Entry;

static int cmp_entry(const void *a, const void *b) {
    const Entry *ea = a, *eb = b;
    if (ea->is_dir != eb->is_dir) return eb->is_dir - ea->is_dir; /* directories first */
    return strcasecmp(ea->name, eb->name);
}

static Entry *list_dir(const char *path, int *out_count) {
    *out_count = 0;
    DIR *d = opendir(path);
    if (!d) return NULL;

    Entry *entries = NULL;
    int n = 0;
    struct dirent *de;
    while ((de = readdir(d)) != NULL) {
        if (strcmp(de->d_name, ".") == 0 || strcmp(de->d_name, "..") == 0) continue;
        if (!FILEPICKER_SHOW_HIDDEN && de->d_name[0] == '.') continue;

        char full[4096];
        snprintf(full, sizeof(full), "%s/%s", path, de->d_name);
        struct stat st;
        if (stat(full, &st) != 0) continue;

        Entry *grown = realloc(entries, sizeof(Entry) * (size_t)(n + 1));
        if (!grown) break;
        entries = grown;
        entries[n].name = strdup(de->d_name);
        entries[n].is_dir = S_ISDIR(st.st_mode);
        n++;
    }
    closedir(d);

    if (entries) qsort(entries, (size_t)n, sizeof(Entry), cmp_entry);
    *out_count = n;
    return entries;
}

static void free_entries(Entry *entries, int count) {
    for (int i = 0; i < count; i++) free(entries[i].name);
    free(entries);
}

char **filepicker_choose_at(Display *dpy, int x, int y, const char *start_dir, int allow_multi, int *out_count) {
    *out_count = 0;
    char *cwd = expand_home(start_dir);

    for (;;) {
        int n = 0;
        Entry *entries = list_dir(cwd, &n);

        int has_parent = strcmp(cwd, "/") != 0;
        int item_count = n + (has_parent ? 1 : 0);

        if (item_count == 0) {
            free(cwd);
            free_entries(entries, n);
            return NULL;
        }

        FMenuEntry *fitems = calloc((size_t)item_count, sizeof(FMenuEntry));
        char **labels = calloc((size_t)item_count, sizeof(char *));
        if (!fitems || !labels) {
            free(fitems);
            free(labels);
            free(cwd);
            free_entries(entries, n);
            return NULL;
        }

        int idx = 0;
        if (has_parent) {
            size_t len = strlen(FILEPICKER_ICON_UP) + 3;
            labels[idx] = malloc(len);
            snprintf(labels[idx], len, "%s..", FILEPICKER_ICON_UP);
            fitems[idx].label = labels[idx];
            fitems[idx].selectable = 1;
            idx++;
        }
        for (int i = 0; i < n; i++) {
            const char *icon = entries[i].is_dir ? FILEPICKER_ICON_DIR : FILEPICKER_ICON_FILE;
            size_t len = strlen(icon) + strlen(entries[i].name) + 1;
            labels[idx] = malloc(len);
            snprintf(labels[idx], len, "%s%s", icon, entries[i].name);
            fitems[idx].label = labels[idx];
            fitems[idx].selectable = 1;
            idx++;
        }

        FMenuResult res = fmenu_show(dpy, x, y, fitems, item_count, allow_multi);

        int chosen_up = has_parent && res.index == 0;

        for (int i = 0; i < item_count; i++) free(labels[i]);
        free(labels);
        free(fitems);

        if (res.checked && res.checked_count > 0) {
            char **paths = malloc(sizeof(char *) * (size_t)res.checked_count);
            int pn = 0;
            if (paths) {
                for (int k = 0; k < res.checked_count; k++) {
                    int fidx = res.checked[k];
                    int entry_idx = fidx - (has_parent ? 1 : 0);
                    if (entry_idx < 0 || entry_idx >= n) continue;      /* ".." checked: ignore */
                    if (entries[entry_idx].is_dir) continue;             /* checked dir: ignore */
                    char *p = malloc(strlen(cwd) + strlen(entries[entry_idx].name) + 2);
                    if (!p) continue;
                    sprintf(p, "%s/%s", cwd, entries[entry_idx].name);
                    paths[pn++] = p;
                }
            }
            free(res.checked);
            free_entries(entries, n);
            free(cwd);
            if (pn == 0) {
                free(paths);
                return NULL;
            }
            *out_count = pn;
            return paths;
        }

        if (res.index < 0) {
            free_entries(entries, n);
            free(cwd);
            return NULL; /* cancelled */
        }

        if (chosen_up) {
            char *slash = strrchr(cwd, '/');
            if (slash && slash != cwd) *slash = '\0';
            free_entries(entries, n);
            continue;
        }

        int entry_idx = res.index - (has_parent ? 1 : 0);
        if (entry_idx < 0 || entry_idx >= n) {
            free_entries(entries, n);
            continue; /* shouldn't happen, but stay safe */
        }

        Entry chosen = entries[entry_idx];
        char *next_path = malloc(strlen(cwd) + strlen(chosen.name) + 2);
        sprintf(next_path, "%s/%s", cwd, chosen.name);

        if (chosen.is_dir) {
            free(cwd);
            cwd = next_path;
            free_entries(entries, n);
            continue;
        }

        free_entries(entries, n);
        free(cwd);

        char **paths = malloc(sizeof(char *));
        if (!paths) return NULL;
        paths[0] = next_path;
        *out_count = 1;
        return paths;
    }
}

char **filepicker_choose(Display *dpy, int x, int y, int allow_multi, int *out_count) {
    return filepicker_choose_at(dpy, x, y, FILEPICKER_START_DIR, allow_multi, out_count);
}

/* Only directories are listed (files are filtered out entirely --
 * they're irrelevant to picking a destination folder), and a
 * synthetic "Select This Folder" entry always sits first, confirming
 * whatever the current directory is. */
char *filepicker_choose_dir_at(Display *dpy, int x, int y, const char *start_dir) {
    char *cwd = expand_home(start_dir);

    for (;;) {
        int n_all = 0;
        Entry *all = list_dir(cwd, &n_all);

        /* keep directories only */
        Entry *dirs = NULL;
        int n = 0;
        for (int i = 0; i < n_all; i++) {
            if (!all[i].is_dir) continue;
            dirs = realloc(dirs, sizeof(Entry) * (size_t)(n + 1));
            dirs[n].name = strdup(all[i].name);
            dirs[n].is_dir = 1;
            n++;
        }
        free_entries(all, n_all);

        int has_parent = strcmp(cwd, "/") != 0;
        int item_count = 1 /* "Select This Folder" */ + (has_parent ? 1 : 0) + n;

        FMenuEntry *fitems = calloc((size_t)item_count, sizeof(FMenuEntry));
        char **labels = calloc((size_t)item_count, sizeof(char *));
        if (!fitems || !labels) {
            free(fitems); free(labels);
            free_entries(dirs, n);
            free(cwd);
            return NULL;
        }

        int idx = 0;
        char select_label[600];
        snprintf(select_label, sizeof(select_label), "\xe2\x9c\x93 Select This Folder (%s)", cwd);
        labels[idx] = strdup(select_label);
        fitems[idx].label = labels[idx];
        fitems[idx].selectable = 1;
        idx++;

        int up_idx = -1;
        if (has_parent) {
            size_t len = strlen(FILEPICKER_ICON_UP) + 3;
            labels[idx] = malloc(len);
            snprintf(labels[idx], len, "%s..", FILEPICKER_ICON_UP);
            fitems[idx].label = labels[idx];
            fitems[idx].selectable = 1;
            up_idx = idx;
            idx++;
        }

        int dirs_start = idx;
        for (int i = 0; i < n; i++) {
            size_t len = strlen(FILEPICKER_ICON_DIR) + strlen(dirs[i].name) + 1;
            labels[idx] = malloc(len);
            snprintf(labels[idx], len, "%s%s", FILEPICKER_ICON_DIR, dirs[i].name);
            fitems[idx].label = labels[idx];
            fitems[idx].selectable = 1;
            idx++;
        }

        FMenuResult res = fmenu_show(dpy, x, y, fitems, item_count, 0);

        for (int i = 0; i < item_count; i++) free(labels[i]);
        free(labels);
        free(fitems);

        if (res.index < 0) {
            free_entries(dirs, n);
            free(cwd);
            return NULL; /* cancelled */
        }

        if (res.index == 0) {
            free_entries(dirs, n);
            return cwd; /* confirmed -- caller takes ownership */
        }

        if (up_idx >= 0 && res.index == up_idx) {
            char *slash = strrchr(cwd, '/');
            if (slash && slash != cwd) *slash = '\0';
            free_entries(dirs, n);
            continue;
        }

        int dir_idx = res.index - dirs_start;
        if (dir_idx < 0 || dir_idx >= n) {
            free_entries(dirs, n);
            continue; /* shouldn't happen, but stay safe */
        }

        char *next_path = malloc(strlen(cwd) + strlen(dirs[dir_idx].name) + 2);
        sprintf(next_path, "%s/%s", cwd, dirs[dir_idx].name);
        free(cwd);
        cwd = next_path;
        free_entries(dirs, n);
    }
}
