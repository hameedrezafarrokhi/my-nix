#include "lastrun.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>
#include <errno.h>

static const char *home_dir(void) {
    const char *h = getenv("HOME");
    if (h && *h) return h;
    struct passwd *pw = getpwuid(getuid());
    return pw ? pw->pw_dir : "/tmp";
}

static void bg_path(char *out, size_t n) {
    snprintf(out, n, "%s/.xwww-bg", home_dir());
}

int lastrun_save(const char *image_path, const char *scale_mode_name, const char *bg_color_hex) {
    char path[4200];
    bg_path(path, sizeof(path));

    FILE *f = fopen(path, "w");
    if (!f) {
        fprintf(stderr, "xwww: warning: could not write %s: %s\n", path, strerror(errno));
        return -1;
    }
    fprintf(f,
        "#!/bin/sh\n"
        "# Written by xwww -- restores the last wallpaper instantly (no\n"
        "# transition). Source this from .xinitrc/autostart at login, e.g.:\n"
        "#   [ -f \"$HOME/.xwww-bg\" ] && sh \"$HOME/.xwww-bg\"\n"
        "xwww '%s' --animation none --scale-mode %s --bg-color '%s' --no-save\n",
        image_path, scale_mode_name, bg_color_hex);
    fclose(f);
    chmod(path, 0755);
    return 0;
}

char *lastrun_get_image(void) {
    char path[4200];
    bg_path(path, sizeof(path));
    FILE *f = fopen(path, "r");
    if (!f) return NULL;

    char line[4096];
    char *result = NULL;
    while (fgets(line, sizeof(line), f)) {
        char *p = strstr(line, "xwww '");
        if (!p) continue;
        p += strlen("xwww '");
        char *end = strchr(p, '\'');
        if (!end) continue;
        *end = 0;
        result = strdup(p);
        break;
    }
    fclose(f);
    return result;
}
