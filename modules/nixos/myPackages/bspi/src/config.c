#include "config.h"
#include "common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

typedef enum {
    SEC_NONE = 0,
    SEC_ICONS,
    SEC_IGNORE,
    SEC_WORKSPACES,
} section_t;

static char *trim(char *s) {
    while (*s == ' ' || *s == '\t' || *s == '\r' || *s == '\n') s++;
    if (*s == '\0') return s;
    char *end = s + strlen(s) - 1;
    while (end > s && (*end == ' ' || *end == '\t' || *end == '\r' || *end == '\n')) {
        *end = '\0';
        end--;
    }
    return s;
}

static void str_tolower_inplace(char *s) {
    for (; *s; s++) *s = (char)tolower((unsigned char)*s);
}

static char *xstrdup(const char *s) {
    size_t n = strlen(s) + 1;
    char *out = malloc(n);
    if (out) memcpy(out, s, n);
    return out;
}

static void handle_workspaces_kv(bspi_config_t *cfg, const char *key, const char *value) {
    /* key is already lower-cased by the caller; expect "wsN" for
     * N in 1..WORKSPACE_PREFIX_MAX. Anything else is ignored rather
     * than treated as a hard error - a typo here shouldn't be fatal. */
    if (strncmp(key, "ws", 2) != 0) return;
    const char *digits = key + 2;
    if (!*digits) return;
    for (const char *p = digits; *p; p++) {
        if (!isdigit((unsigned char)*p)) return;
    }
    long n = strtol(digits, NULL, 10);
    if (n < 1 || n > WORKSPACE_PREFIX_MAX) {
        LOGW("ignoring '%s' in [workspaces] - only ws1..ws%d are supported",
             key, WORKSPACE_PREFIX_MAX);
        return;
    }
    free(cfg->ws_prefix[n]);
    cfg->ws_prefix[n] = xstrdup(value);
}

int bspi_config_load(bspi_config_t *cfg, const char *path, char *errbuf, size_t errbuf_len) {
    memset(cfg, 0, sizeof(*cfg));
    icon_table_init(&cfg->icons);
    ignore_table_init(&cfg->ignore);

    FILE *f = fopen(path, "r");
    if (!f) {
        if (errbuf) snprintf(errbuf, errbuf_len, "cannot open '%s': %s", path, strerror(errno));
        return -1;
    }

    char *line = NULL;
    size_t linecap = 0;
    ssize_t len;

    section_t section = SEC_NONE;
    long lineno = 0;

    while ((len = getline(&line, &linecap, f)) != -1) {
        lineno++;
        (void)len;
        char *raw = line;

        if (lineno == 1 && (unsigned char)raw[0] == 0xEF &&
            (unsigned char)raw[1] == 0xBB && (unsigned char)raw[2] == 0xBF) {
            raw += 3; /* strip a UTF-8 BOM if present */
        }

        char *s = trim(raw);
        if (*s == '\0' || *s == ';' || *s == '#') continue; /* blank / comment */

        if (*s == '[') {
            char *close = strchr(s, ']');
            if (close) {
                *close = '\0';
                char name[64];
                snprintf(name, sizeof(name), "%s", s + 1);
                str_tolower_inplace(name);
                if (strcmp(name, "icons") == 0) section = SEC_ICONS;
                else if (strcmp(name, "ignore") == 0) section = SEC_IGNORE;
                else if (strcmp(name, "workspaces") == 0) section = SEC_WORKSPACES;
                else section = SEC_NONE;
            } else {
                section = SEC_NONE;
            }
            continue;
        }

        if (section == SEC_NONE) continue;

        char *eq = strchr(s, '=');
        char *colon = strchr(s, ':');
        char *delim = eq;
        if (colon && (!eq || colon < eq)) delim = colon;
        if (!delim) continue; /* malformed line - ignore rather than abort */

        *delim = '\0';
        char *key = trim(s);
        char *value = trim(delim + 1);
        if (*key == '\0') continue;

        str_tolower_inplace(key);

        switch (section) {
            case SEC_ICONS:
                icon_table_add(&cfg->icons, key, value);
                break;
            case SEC_IGNORE:
                ignore_table_add(&cfg->ignore, key, value);
                break;
            case SEC_WORKSPACES:
                handle_workspaces_kv(cfg, key, value);
                break;
            default:
                break;
        }
    }

    free(line);
    fclose(f);
    return 0;
}

void bspi_config_free(bspi_config_t *cfg) {
    icon_table_free(&cfg->icons);
    ignore_table_free(&cfg->ignore);
    for (int i = 0; i <= WORKSPACE_PREFIX_MAX; i++) {
        free(cfg->ws_prefix[i]);
        cfg->ws_prefix[i] = NULL;
    }
}

const char *bspi_config_ws_prefix(const bspi_config_t *cfg, int ws_index) {
    if (ws_index < 1 || ws_index > WORKSPACE_PREFIX_MAX) return NULL;
    return cfg->ws_prefix[ws_index];
}
