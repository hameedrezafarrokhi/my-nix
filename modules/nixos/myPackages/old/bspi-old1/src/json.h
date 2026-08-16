#ifndef BSPI_JSON_H
#define BSPI_JSON_H

#include <stddef.h>

/*
 * A tiny, dependency-free JSON parser.
 *
 * It's intentionally not a general-purpose library: it's shaped around
 * what we need to walk bspwm's `bspc wm -d` tree (objects, arrays,
 * strings, numbers, booleans, null) as cheaply as possible.
 *
 * All allocation happens out of an arena (a handful of large blocks,
 * bump-allocated). The whole tree for one snapshot is freed in one call
 * instead of walking it and calling free() on every node individually -
 * this matters because a busy desktop can easily have a few hundred
 * JSON values in it and we may re-parse a fresh tree many times a
 * second while windows are opening/closing rapidly.
 */

typedef struct json_arena_block json_arena_block_t;

typedef struct {
    json_arena_block_t *head;    /* for freeing */
    json_arena_block_t *current; /* being bump-allocated */
} json_arena_t;

void json_arena_init(json_arena_t *a);
void json_arena_free(json_arena_t *a);

typedef enum {
    JT_NULL = 0,
    JT_BOOL,
    JT_NUMBER,
    JT_STRING,
    JT_ARRAY,
    JT_OBJECT,
} json_type_t;

typedef struct json_member json_member_t;

typedef struct json_value {
    json_type_t type;
    union {
        int boolean;
        double number;
        char *string;
        json_member_t *object; /* linked list of members */
    } u;
    struct json_value *array_head; /* used only when this value IS an array */
    struct json_value *next;       /* sibling link when this value is an array element */
} json_value_t;

struct json_member {
    char *key;
    json_value_t *value;
    json_member_t *next;
};

/* Parses `text` (need not be NUL terminated if len is given correctly).
 * Returns the root value, or NULL on a parse error (errbuf, if given,
 * is filled with a short human readable reason). Everything returned is
 * owned by the arena; nothing needs to be individually freed. */
json_value_t *json_parse(const char *text, size_t len, json_arena_t *arena,
                          char *errbuf, size_t errbuf_len);

/* Accessors. All are NULL/type safe: passing NULL or a mistyped value
 * just yields the fallback / NULL rather than crashing, since a
 * malformed or unexpected bspwm response should never take the whole
 * daemon down. */
json_value_t *json_object_get(const json_value_t *obj, const char *key);
const char   *json_get_string(const json_value_t *v); /* NULL if absent/not a string */
int            json_get_bool(const json_value_t *v, int default_val);
long long      json_get_int(const json_value_t *v, long long default_val);
int            json_is_null(const json_value_t *v); /* true if v is NULL or JSON null */

#endif /* BSPI_JSON_H */
