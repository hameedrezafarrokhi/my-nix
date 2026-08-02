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
    SEC_WS_UNIVERSAL,
    SEC_WS_OCCUPIED_FOCUSED,
    SEC_WS_OCCUPIED_IDLE,
    SEC_WS_EMPTY_FOCUSED,
    SEC_WS_EMPTY_IDLE,
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

/* Parses "wsN" (N in 1..WORKSPACE_PREFIX_MAX) and returns N, or 0 if
 * `key` doesn't match that shape - a typo here is logged and ignored
 * rather than treated as a hard error. */
static int parse_ws_index(const char *key, const char *section_label) {
    if (strncmp(key, "ws", 2) != 0) return 0;
    const char *digits = key + 2;
    if (!*digits) return 0;
    for (const char *p = digits; *p; p++) {
        if (!isdigit((unsigned char)*p)) return 0;
    }
    long n = strtol(digits, NULL, 10);
    if (n < 1 || n > WORKSPACE_PREFIX_MAX) {
        LOGW("ignoring '%s' in [%s] - only ws1..ws%d are supported",
             key, section_label, WORKSPACE_PREFIX_MAX);
        return 0;
    }
    return (int)n;
}

static void handle_universal_ws_kv(bspi_config_t *cfg, const char *key, const char *value) {
    int n = parse_ws_index(key, "workspaces");
    if (n == 0) return;
    free(cfg->ws_prefix[n]);
    cfg->ws_prefix[n] = xstrdup(value);
}

static void handle_category_ws_kv(bspi_config_t *cfg, ws_category_t cat,
                                   const char *section_label,
                                   const char *key, const char *value) {
    int n = parse_ws_index(key, section_label);
    if (n == 0) return;
    free(cfg->ws_cat_prefix[cat][n]);
    cfg->ws_cat_prefix[cat][n] = xstrdup(value);
    cfg->ws_cat_defined_count[cat]++;
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
                else if (strcmp(name, "workspaces") == 0) section = SEC_WS_UNIVERSAL;
                else if (strcmp(name, "workspaces-occupied-focused") == 0) section = SEC_WS_OCCUPIED_FOCUSED;
                else if (strcmp(name, "workspaces-occupied") == 0) section = SEC_WS_OCCUPIED_IDLE;
                else if (strcmp(name, "workspaces-unoccupied-focused") == 0) section = SEC_WS_EMPTY_FOCUSED;
                else if (strcmp(name, "workspaces-unoccupied") == 0) section = SEC_WS_EMPTY_IDLE;
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
            case SEC_WS_UNIVERSAL:
                handle_universal_ws_kv(cfg, key, value);
                break;
            case SEC_WS_OCCUPIED_FOCUSED:
                handle_category_ws_kv(cfg, WS_CAT_OCCUPIED_FOCUSED, "workspaces-occupied-focused", key, value);
                break;
            case SEC_WS_OCCUPIED_IDLE:
                handle_category_ws_kv(cfg, WS_CAT_OCCUPIED_IDLE, "workspaces-occupied", key, value);
                break;
            case SEC_WS_EMPTY_FOCUSED:
                handle_category_ws_kv(cfg, WS_CAT_EMPTY_FOCUSED, "workspaces-unoccupied-focused", key, value);
                break;
            case SEC_WS_EMPTY_IDLE:
                handle_category_ws_kv(cfg, WS_CAT_EMPTY_IDLE, "workspaces-unoccupied", key, value);
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
        for (int c = 0; c < WS_CAT_COUNT; c++) {
            free(cfg->ws_cat_prefix[c][i]);
            cfg->ws_cat_prefix[c][i] = NULL;
        }
    }
    for (int c = 0; c < WS_CAT_COUNT; c++) cfg->ws_cat_defined_count[c] = 0;
}

/* The same-occupancy, opposite-focus counterpart of each category -
 * used as the first fallback when the exact state's section doesn't
 * have a value for a given position (see the precedence rules in
 * config.h). */
static ws_category_t same_occupancy_counterpart(ws_category_t cat) {
    switch (cat) {
        case WS_CAT_OCCUPIED_FOCUSED: return WS_CAT_OCCUPIED_IDLE;
        case WS_CAT_OCCUPIED_IDLE:    return WS_CAT_OCCUPIED_FOCUSED;
        case WS_CAT_EMPTY_FOCUSED:    return WS_CAT_EMPTY_IDLE;
        case WS_CAT_EMPTY_IDLE:       return WS_CAT_EMPTY_FOCUSED;
        default:                      return cat;
    }
}

const char *bspi_config_ws_prefix_for(const bspi_config_t *cfg, int ws_index,
                                       int occupied, int focused) {
    if (ws_index < 1 || ws_index > WORKSPACE_PREFIX_MAX) return NULL;

    int defined_categories = 0;
    ws_category_t only_defined = WS_CAT_OCCUPIED_FOCUSED;
    for (int c = 0; c < WS_CAT_COUNT; c++) {
        if (cfg->ws_cat_defined_count[c] > 0) {
            defined_categories++;
            only_defined = (ws_category_t)c;
        }
    }

    if (defined_categories == 0) {
        /* Original single-tier behaviour. */
        return cfg->ws_prefix[ws_index];
    }

    if (defined_categories == 1) {
        /* The lone active category stands in for `[workspaces]`
         * entirely, for every state. */
        return cfg->ws_cat_prefix[only_defined][ws_index];
    }

    ws_category_t target = occupied
        ? (focused ? WS_CAT_OCCUPIED_FOCUSED : WS_CAT_OCCUPIED_IDLE)
        : (focused ? WS_CAT_EMPTY_FOCUSED : WS_CAT_EMPTY_IDLE);

    if (cfg->ws_cat_prefix[target][ws_index]) return cfg->ws_cat_prefix[target][ws_index];

    ws_category_t fallback = same_occupancy_counterpart(target);
    if (cfg->ws_cat_prefix[fallback][ws_index]) return cfg->ws_cat_prefix[fallback][ws_index];

    return cfg->ws_prefix[ws_index];
}
