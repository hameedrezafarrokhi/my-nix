#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

#include "state_file.h"

/* Builds ~/.cache/polybar-kdeconnect/last-device (honoring
 * $XDG_CACHE_HOME if set), creating the directory if needed. Returns a
 * malloc'd path, or NULL if we have no usable home directory at all. */
static char *state_file_path(void) {
    const char *cache_home = getenv("XDG_CACHE_HOME");
    char base[4096];

    if (cache_home && cache_home[0] != '\0') {
        snprintf(base, sizeof(base), "%s/polybar-kdeconnect", cache_home);
    } else {
        const char *home = getenv("HOME");
        if (!home || home[0] == '\0') return NULL;
        snprintf(base, sizeof(base), "%s/.cache/polybar-kdeconnect", home);
    }

    if (mkdir(base, 0700) != 0 && errno != EEXIST) {
        /* best effort -- if we can't create it, the later fopen will
         * just fail too, and callers already treat that as "no state" */
    }

    char *path = malloc(strlen(base) + strlen("/last-device") + 1);
    if (!path) return NULL;
    sprintf(path, "%s/last-device", base);
    return path;
}

void save_last_device(const char *device_id) {
    if (!device_id || device_id[0] == '\0') return;
    char *path = state_file_path();
    if (!path) return;

    FILE *f = fopen(path, "w");
    if (f) {
        fputs(device_id, f);
        fclose(f);
    }
    free(path);
}

char *load_last_device(void) {
    char *path = state_file_path();
    if (!path) return NULL;

    FILE *f = fopen(path, "r");
    free(path);
    if (!f) return NULL;

    char buf[256];
    char *result = NULL;
    if (fgets(buf, sizeof(buf), f)) {
        size_t len = strlen(buf);
        while (len > 0 && (buf[len - 1] == '\n' || buf[len - 1] == '\r')) buf[--len] = '\0';
        if (len > 0) result = strdup(buf);
    }
    fclose(f);
    return result;
}
