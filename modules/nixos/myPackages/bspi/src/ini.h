#ifndef BSPI_INI_H
#define BSPI_INI_H

#include <stddef.h>

/*
 * A small hash table for the `[Icons]` section: WM class -> icon
 * glyph(s), keyed case-insensitively (matching Python's configparser,
 * which lower-cases option names by default).
 *
 * Parsing the actual bspi.ini file happens in config.c, which reads
 * every section (Icons, Ignore, Workspaces) in one pass and calls
 * icon_table_add() for each entry under [Icons]. This header only
 * owns the table itself and its lookups.
 */

#define ICON_TABLE_BUCKETS 256

typedef struct icon_entry {
    char *key;   /* lower-cased WM class */
    char *value; /* icon glyph(s), verbatim */
    struct icon_entry *next;
} icon_entry_t;

typedef struct {
    icon_entry_t *buckets[ICON_TABLE_BUCKETS];
    size_t count;
} icon_table_t;

void icon_table_init(icon_table_t *t);

/* Inserts/overwrites one entry. `key` is lower-cased in place by the
 * caller's convention (config.c already lower-cases every option key
 * before calling this), `value` is copied verbatim. A duplicate key
 * (redefined later in the file) replaces the earlier value. */
void icon_table_add(icon_table_t *t, const char *key, const char *value);

/* Frees every entry (but not *t itself). Safe to call on a
 * zero-initialized or already-freed table. */
void icon_table_free(icon_table_t *t);

/* Case-insensitive lookup. Falls back to the `_other` entry if
 * class_name has no direct match, and returns NULL if neither exists
 * (an empty desktop name is a perfectly fine outcome - the daemon
 * never crashes over a missing icon). */
const char *icon_table_lookup(const icon_table_t *t, const char *class_name);

#endif /* BSPI_INI_H */

