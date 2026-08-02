#include "ignore.h"

#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <fnmatch.h>

static char *xstrdup2(const char *s) {
    size_t n = strlen(s) + 1;
    char *out = malloc(n);
    if (out) memcpy(out, s, n);
    return out;
}

static char *trim2(char *s) {
    while (*s == ' ' || *s == '\t' || *s == '\r' || *s == '\n') s++;
    if (*s == '\0') return s;
    char *end = s + strlen(s) - 1;
    while (end > s && (*end == ' ' || *end == '\t' || *end == '\r' || *end == '\n')) {
        *end = '\0';
        end--;
    }
    return s;
}

static void str_list_add(bspi_str_list_t *l, const char *s) {
    if (l->count == l->cap) {
        int ncap = l->cap ? l->cap * 2 : 8;
        char **ni = realloc(l->items, (size_t)ncap * sizeof(char *));
        if (!ni) return;
        l->items = ni;
        l->cap = ncap;
    }
    char *copy = xstrdup2(s);
    if (!copy) return;
    l->items[l->count++] = copy;
}

static void str_list_free(bspi_str_list_t *l) {
    for (int i = 0; i < l->count; i++) free(l->items[i]);
    free(l->items);
    l->items = NULL;
    l->count = 0;
    l->cap = 0;
}

static int str_list_matches(const bspi_str_list_t *l, const char *value) {
    if (!value) return 0;
    for (int i = 0; i < l->count; i++) {
        if (fnmatch(l->items[i], value, FNM_CASEFOLD) == 0) return 1;
    }
    return 0;
}

void ignore_table_init(ignore_table_t *t) {
    memset(t, 0, sizeof(*t));
}

void ignore_table_free(ignore_table_t *t) {
    str_list_free(&t->class_patterns);
    str_list_free(&t->instance_patterns);
    str_list_free(&t->title_patterns);
    str_list_free(&t->any_patterns);
}

void ignore_table_add(ignore_table_t *t, const char *key, const char *csv_value) {
    bspi_str_list_t *target = NULL;
    if (strcasecmp(key, "class") == 0) target = &t->class_patterns;
    else if (strcasecmp(key, "instance") == 0) target = &t->instance_patterns;
    else if (strcasecmp(key, "title") == 0) target = &t->title_patterns;
    else if (strcasecmp(key, "all") == 0) target = &t->any_patterns;
    else return; /* unknown key under [ignore] - ignored, not fatal */

    char *dup = xstrdup2(csv_value);
    if (!dup) return;

    char *saveptr = NULL;
    char *tok = strtok_r(dup, ",", &saveptr);
    while (tok) {
        char *trimmed = trim2(tok);
        if (*trimmed) str_list_add(target, trimmed);
        tok = strtok_r(NULL, ",", &saveptr);
    }
    free(dup);
}

int ignore_table_needs_title(const ignore_table_t *t) {
    return t->title_patterns.count > 0 || t->any_patterns.count > 0;
}

int ignore_table_matches(const ignore_table_t *t, const char *class_name,
                          const char *instance_name, const char *title) {
    if (str_list_matches(&t->class_patterns, class_name)) return 1;
    if (str_list_matches(&t->instance_patterns, instance_name)) return 1;
    if (title && str_list_matches(&t->title_patterns, title)) return 1;

    if (str_list_matches(&t->any_patterns, class_name)) return 1;
    if (str_list_matches(&t->any_patterns, instance_name)) return 1;
    if (title && str_list_matches(&t->any_patterns, title)) return 1;

    return 0;
}
