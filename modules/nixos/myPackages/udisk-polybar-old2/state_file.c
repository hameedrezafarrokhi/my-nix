#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h> /* strcasecmp */
#include <sys/stat.h>
#include <unistd.h> /* getpid */
#include <errno.h>

#include "state_file.h"

/* Builds $XDG_CACHE_HOME/polybar-udisks/<name> (or
 * ~/.cache/polybar-udisks/<name>), creating the directory if needed.
 * Returns a malloc'd path, or NULL if we have no usable home dir. */
static char *state_path(const char *name) {
    const char *cache_home = getenv("XDG_CACHE_HOME");
    char base[4096];

    if (cache_home && cache_home[0] != '\0') {
        snprintf(base, sizeof(base), "%s/polybar-udisks", cache_home);
    } else {
        const char *home = getenv("HOME");
        if (!home || home[0] == '\0') return NULL;
        snprintf(base, sizeof(base), "%s/.cache/polybar-udisks", home);
    }

    if (mkdir(base, 0700) != 0 && errno != EEXIST) {
        /* best effort -- a later fopen failing is treated as "no state" anyway */
    }

    size_t len = strlen(base) + 1 + strlen(name) + 1;
    char *path = malloc(len);
    if (!path) return NULL;
    snprintf(path, len, "%s/%s", base, name);
    return path;
}

void save_last_device(const char *device_id) {
    if (!device_id || device_id[0] == '\0') return;
    char *path = state_path("last-device");
    if (!path) return;
    FILE *f = fopen(path, "w");
    if (f) {
        fputs(device_id, f);
        fclose(f);
    }
    free(path);
}

char *load_last_device(void) {
    char *path = state_path("last-device");
    if (!path) return NULL;
    FILE *f = fopen(path, "r");
    free(path);
    if (!f) return NULL;

    char buf[512];
    char *result = NULL;
    if (fgets(buf, sizeof(buf), f)) {
        size_t len = strlen(buf);
        while (len > 0 && (buf[len - 1] == '\n' || buf[len - 1] == '\r')) buf[--len] = '\0';
        if (len > 0) result = strdup(buf);
    }
    fclose(f);
    return result;
}

/* mount-links file format: one "UUID\tPATH\n" pair per line. Small,
 * flat, rewritten in full on every change -- there will never be more
 * than a handful of entries, so this isn't worth a real database. */

char *state_get_symlink(const char *uuid) {
    if (!uuid || !uuid[0]) return NULL;
    char *path = state_path("mount-links");
    if (!path) return NULL;
    FILE *f = fopen(path, "r");
    free(path);
    if (!f) return NULL;

    char line[4096];
    char *result = NULL;
    while (fgets(line, sizeof(line), f)) {
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';
        char *tab = strchr(line, '\t');
        if (!tab) continue;
        *tab = '\0';
        if (!strcasecmp(line, uuid) && tab[1] != '\0') {
            result = strdup(tab + 1);
            break;
        }
    }
    fclose(f);
    return result;
}

void state_set_symlink(const char *uuid, const char *path_value) {
    if (!uuid || !uuid[0]) return;
    char *path = state_path("mount-links");
    if (!path) return;

    /* Read existing entries, drop any for this uuid, optionally add
     * the new one, rewrite the whole (tiny) file. */
    char **keys = NULL, **vals = NULL;
    int n = 0;

    FILE *in = fopen(path, "r");
    if (in) {
        char line[4096];
        while (fgets(line, sizeof(line), in)) {
            size_t len = strlen(line);
            while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';
            char *tab = strchr(line, '\t');
            if (!tab) continue;
            *tab = '\0';
            if (!strcasecmp(line, uuid)) continue; /* dropped -- replaced below if path_value set */
            keys = realloc(keys, sizeof(char *) * (n + 1));
            vals = realloc(vals, sizeof(char *) * (n + 1));
            keys[n] = strdup(line);
            vals[n] = strdup(tab + 1);
            n++;
        }
        fclose(in);
    }

    FILE *out = fopen(path, "w");
    if (out) {
        for (int i = 0; i < n; i++) fprintf(out, "%s\t%s\n", keys[i], vals[i]);
        if (path_value && path_value[0]) fprintf(out, "%s\t%s\n", uuid, path_value);
        fclose(out);
    }

    for (int i = 0; i < n; i++) { free(keys[i]); free(vals[i]); }
    free(keys);
    free(vals);
    free(path);
}

void save_daemon_pid(void) {
    char *path = state_path("daemon.pid");
    if (!path) return;
    FILE *f = fopen(path, "w");
    if (f) {
        fprintf(f, "%ld", (long)getpid());
        fclose(f);
    }
    free(path);
}

pid_t load_daemon_pid(void) {
    char *path = state_path("daemon.pid");
    if (!path) return 0;
    FILE *f = fopen(path, "r");
    free(path);
    if (!f) return 0;
    long v = 0;
    int got = fscanf(f, "%ld", &v);
    fclose(f);
    return (got == 1 && v > 0) ? (pid_t)v : 0;
}
