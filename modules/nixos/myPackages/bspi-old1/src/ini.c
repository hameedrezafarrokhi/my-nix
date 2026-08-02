#include "ini.h"
#include "common.h"

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static unsigned long hash_str(const char *s) {
    /* djb2 */
    unsigned long h = 5381;
    int c;
    while ((c = (unsigned char)*s++)) {
        h = ((h << 5) + h) + (unsigned long)c;
    }
    return h;
}

static char *xstrdup(const char *s) {
    size_t n = strlen(s) + 1;
    char *out = malloc(n);
    if (out) memcpy(out, s, n);
    return out;
}

static void str_tolower_inplace(char *s) {
    for (; *s; s++) *s = (char)tolower((unsigned char)*s);
}

void icon_table_init(icon_table_t *t) {
    memset(t, 0, sizeof(*t));
}

void icon_table_add(icon_table_t *t, const char *key, const char *value) {
    unsigned long h = hash_str(key) % ICON_TABLE_BUCKETS;

    /* A duplicate key (redefined later in the file) replaces the
     * earlier value, matching configparser's last-one-wins behaviour. */
    for (icon_entry_t *e = t->buckets[h]; e; e = e->next) {
        if (strcmp(e->key, key) == 0) {
            char *nv = xstrdup(value);
            if (nv) { free(e->value); e->value = nv; }
            return;
        }
    }

    icon_entry_t *e = malloc(sizeof(icon_entry_t));
    if (!e) return;
    e->key = xstrdup(key);
    e->value = xstrdup(value);
    if (!e->key || !e->value) {
        free(e->key);
        free(e->value);
        free(e);
        return;
    }
    e->next = t->buckets[h];
    t->buckets[h] = e;
    t->count++;
}

void icon_table_free(icon_table_t *t) {
    for (int i = 0; i < ICON_TABLE_BUCKETS; i++) {
        icon_entry_t *e = t->buckets[i];
        while (e) {
            icon_entry_t *next = e->next;
            free(e->key);
            free(e->value);
            free(e);
            e = next;
        }
        t->buckets[i] = NULL;
    }
    t->count = 0;
}

const char *icon_table_lookup(const icon_table_t *t, const char *class_name) {
    if (!class_name) return NULL;

    char buf[256];
    size_t n = strlen(class_name);
    if (n >= sizeof(buf)) n = sizeof(buf) - 1;
    memcpy(buf, class_name, n);
    buf[n] = '\0';
    str_tolower_inplace(buf);

    unsigned long h = hash_str(buf) % ICON_TABLE_BUCKETS;
    for (icon_entry_t *e = t->buckets[h]; e; e = e->next) {
        if (strcmp(e->key, buf) == 0) return e->value;
    }

    /* Fall back to `_other`. */
    h = hash_str("_other") % ICON_TABLE_BUCKETS;
    for (icon_entry_t *e = t->buckets[h]; e; e = e->next) {
        if (strcmp(e->key, "_other") == 0) return e->value;
    }
    return NULL;
}
