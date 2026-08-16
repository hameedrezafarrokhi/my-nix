#include "json.h"

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

/* ---------------------------------------------------------------- arena */

#define ARENA_BLOCK_SIZE (32 * 1024)

struct json_arena_block {
    struct json_arena_block *next;
    size_t used;
    size_t cap;
    unsigned char data[];
};

void json_arena_init(json_arena_t *a) {
    a->head = NULL;
    a->current = NULL;
}

static json_arena_block_t *arena_new_block(size_t min_size) {
    size_t cap = ARENA_BLOCK_SIZE;
    if (min_size > cap) cap = min_size;
    json_arena_block_t *b = malloc(sizeof(json_arena_block_t) + cap);
    if (!b) return NULL;
    b->next = NULL;
    b->used = 0;
    b->cap = cap;
    return b;
}

static void *arena_alloc(json_arena_t *a, size_t n) {
    /* 8-byte align so double/pointer fields inside json_value_t never
     * land on an unaligned address. */
    n = (n + 7u) & ~((size_t)7u);

    if (!a->current || a->current->used + n > a->current->cap) {
        json_arena_block_t *b = arena_new_block(n);
        if (!b) return NULL;
        if (a->current) {
            a->current->next = b;
        } else {
            a->head = b;
        }
        a->current = b;
    }

    void *p = a->current->data + a->current->used;
    a->current->used += n;
    return p;
}

void json_arena_free(json_arena_t *a) {
    json_arena_block_t *b = a->head;
    while (b) {
        json_arena_block_t *next = b->next;
        free(b);
        b = next;
    }
    a->head = NULL;
    a->current = NULL;
}

/* --------------------------------------------------------------- parser */

typedef struct {
    const char *p;
    const char *end;
    json_arena_t *arena;
    char *errbuf;
    size_t errbuf_len;
    int failed;
} parser_t;

static void perr(parser_t *ps, const char *msg) {
    if (ps->failed) return; /* keep the first error */
    ps->failed = 1;
    if (ps->errbuf && ps->errbuf_len) {
        size_t offset = (size_t)(ps->p - (ps->end - (ps->p - ps->end))); /* unused, kept simple below */
        (void)offset;
        snprintf(ps->errbuf, ps->errbuf_len, "%s", msg);
    }
}

static void skip_ws(parser_t *ps) {
    while (ps->p < ps->end) {
        char c = *ps->p;
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
            ps->p++;
        } else {
            break;
        }
    }
}

static int at_end(parser_t *ps) { return ps->p >= ps->end; }

static json_value_t *new_value(parser_t *ps, json_type_t type) {
    json_value_t *v = arena_alloc(ps->arena, sizeof(json_value_t));
    if (!v) { perr(ps, "out of memory"); return NULL; }
    memset(v, 0, sizeof(*v));
    v->type = type;
    return v;
}

static json_value_t *parse_value(parser_t *ps);

/* Decodes a JSON string literal starting at the opening quote. Advances
 * ps->p past the closing quote. Returns an arena-owned NUL terminated
 * string, or NULL on error. */
static char *parse_string_raw(parser_t *ps) {
    if (at_end(ps) || *ps->p != '"') { perr(ps, "expected string"); return NULL; }
    ps->p++; /* skip opening quote */

    const char *start = ps->p;
    /* First pass: find the closing quote and whether any escapes exist,
     * so we can allocate exactly once. */
    int has_escape = 0;
    const char *s = ps->p;
    while (s < ps->end && *s != '"') {
        if (*s == '\\') {
            has_escape = 1;
            s++;
            if (s >= ps->end) { perr(ps, "unterminated escape"); return NULL; }
        }
        s++;
    }
    if (s >= ps->end) { perr(ps, "unterminated string"); return NULL; }
    size_t raw_len = (size_t)(s - start);

    char *out = arena_alloc(ps->arena, raw_len + 1);
    if (!out) { perr(ps, "out of memory"); return NULL; }

    if (!has_escape) {
        memcpy(out, start, raw_len);
        out[raw_len] = '\0';
        ps->p = s + 1;
        return out;
    }

    size_t oi = 0;
    const char *q = start;
    while (q < s) {
        if (*q == '\\') {
            q++;
            switch (*q) {
                case '"':  out[oi++] = '"';  q++; break;
                case '\\': out[oi++] = '\\'; q++; break;
                case '/':  out[oi++] = '/';  q++; break;
                case 'b':  out[oi++] = '\b'; q++; break;
                case 'f':  out[oi++] = '\f'; q++; break;
                case 'n':  out[oi++] = '\n'; q++; break;
                case 'r':  out[oi++] = '\r'; q++; break;
                case 't':  out[oi++] = '\t'; q++; break;
                case 'u': {
                    q++;
                    if (q + 4 > s) { perr(ps, "bad unicode escape"); return NULL; }
                    unsigned cp = 0;
                    for (int i = 0; i < 4; i++) {
                        char c = q[i];
                        cp <<= 4;
                        if (c >= '0' && c <= '9') cp |= (unsigned)(c - '0');
                        else if (c >= 'a' && c <= 'f') cp |= (unsigned)(c - 'a' + 10);
                        else if (c >= 'A' && c <= 'F') cp |= (unsigned)(c - 'A' + 10);
                        else { perr(ps, "bad unicode escape"); return NULL; }
                    }
                    q += 4;
                    /* Encode as UTF-8. We don't bother with surrogate
                     * pair joining - WM_CLASS values are effectively
                     * always ASCII, so this path barely matters; we
                     * just need to not corrupt the byte stream. */
                    if (cp < 0x80) {
                        out[oi++] = (char)cp;
                    } else if (cp < 0x800) {
                        out[oi++] = (char)(0xC0 | (cp >> 6));
                        out[oi++] = (char)(0x80 | (cp & 0x3F));
                    } else {
                        out[oi++] = (char)(0xE0 | (cp >> 12));
                        out[oi++] = (char)(0x80 | ((cp >> 6) & 0x3F));
                        out[oi++] = (char)(0x80 | (cp & 0x3F));
                    }
                    break;
                }
                default:
                    perr(ps, "bad escape");
                    return NULL;
            }
        } else {
            out[oi++] = *q++;
        }
    }
    out[oi] = '\0';
    ps->p = s + 1;
    return out;
}

static json_value_t *parse_string(parser_t *ps) {
    char *s = parse_string_raw(ps);
    if (!s) return NULL;
    json_value_t *v = new_value(ps, JT_STRING);
    if (!v) return NULL;
    v->u.string = s;
    return v;
}

static json_value_t *parse_number(parser_t *ps) {
    const char *start = ps->p;
    if (!at_end(ps) && *ps->p == '-') ps->p++;
    while (!at_end(ps) && isdigit((unsigned char)*ps->p)) ps->p++;
    if (!at_end(ps) && *ps->p == '.') {
        ps->p++;
        while (!at_end(ps) && isdigit((unsigned char)*ps->p)) ps->p++;
    }
    if (!at_end(ps) && (*ps->p == 'e' || *ps->p == 'E')) {
        ps->p++;
        if (!at_end(ps) && (*ps->p == '+' || *ps->p == '-')) ps->p++;
        while (!at_end(ps) && isdigit((unsigned char)*ps->p)) ps->p++;
    }
    if (ps->p == start) { perr(ps, "expected number"); return NULL; }

    char buf[64];
    size_t n = (size_t)(ps->p - start);
    if (n >= sizeof(buf)) n = sizeof(buf) - 1;
    memcpy(buf, start, n);
    buf[n] = '\0';

    json_value_t *v = new_value(ps, JT_NUMBER);
    if (!v) return NULL;
    v->u.number = strtod(buf, NULL);
    return v;
}

static int match_literal(parser_t *ps, const char *lit) {
    size_t n = strlen(lit);
    if ((size_t)(ps->end - ps->p) < n) return 0;
    if (memcmp(ps->p, lit, n) != 0) return 0;
    ps->p += n;
    return 1;
}

static json_value_t *parse_object(parser_t *ps) {
    ps->p++; /* { */
    json_value_t *v = new_value(ps, JT_OBJECT);
    if (!v) return NULL;

    skip_ws(ps);
    if (!at_end(ps) && *ps->p == '}') { ps->p++; return v; }

    json_member_t *tail = NULL;
    for (;;) {
        skip_ws(ps);
        if (at_end(ps) || *ps->p != '"') { perr(ps, "expected object key"); return NULL; }
        char *key = parse_string_raw(ps);
        if (!key) return NULL;

        skip_ws(ps);
        if (at_end(ps) || *ps->p != ':') { perr(ps, "expected ':'"); return NULL; }
        ps->p++;
        skip_ws(ps);

        json_value_t *val = parse_value(ps);
        if (!val) return NULL;

        json_member_t *m = arena_alloc(ps->arena, sizeof(json_member_t));
        if (!m) { perr(ps, "out of memory"); return NULL; }
        m->key = key;
        m->value = val;
        m->next = NULL;
        if (tail) tail->next = m; else v->u.object = m;
        tail = m;

        skip_ws(ps);
        if (at_end(ps)) { perr(ps, "unterminated object"); return NULL; }
        if (*ps->p == ',') { ps->p++; continue; }
        if (*ps->p == '}') { ps->p++; break; }
        perr(ps, "expected ',' or '}'");
        return NULL;
    }
    return v;
}

static json_value_t *parse_array(parser_t *ps) {
    ps->p++; /* [ */
    json_value_t *v = new_value(ps, JT_ARRAY);
    if (!v) return NULL;

    skip_ws(ps);
    if (!at_end(ps) && *ps->p == ']') { ps->p++; return v; }

    json_value_t *tail = NULL;
    for (;;) {
        skip_ws(ps);
        json_value_t *el = parse_value(ps);
        if (!el) return NULL;
        el->next = NULL;
        if (tail) tail->next = el; else v->array_head = el;
        tail = el;

        skip_ws(ps);
        if (at_end(ps)) { perr(ps, "unterminated array"); return NULL; }
        if (*ps->p == ',') { ps->p++; continue; }
        if (*ps->p == ']') { ps->p++; break; }
        perr(ps, "expected ',' or ']'");
        return NULL;
    }
    return v;
}

static json_value_t *parse_value(parser_t *ps) {
    skip_ws(ps);
    if (at_end(ps)) { perr(ps, "unexpected end of input"); return NULL; }

    char c = *ps->p;
    if (c == '{') return parse_object(ps);
    if (c == '[') return parse_array(ps);
    if (c == '"') return parse_string(ps);
    if (c == '-' || isdigit((unsigned char)c)) return parse_number(ps);
    if (match_literal(ps, "true"))  { json_value_t *v = new_value(ps, JT_BOOL); if (v) v->u.boolean = 1; return v; }
    if (match_literal(ps, "false")) { json_value_t *v = new_value(ps, JT_BOOL); if (v) v->u.boolean = 0; return v; }
    if (match_literal(ps, "null"))  { return new_value(ps, JT_NULL); }

    perr(ps, "unexpected character");
    return NULL;
}

json_value_t *json_parse(const char *text, size_t len, json_arena_t *arena,
                          char *errbuf, size_t errbuf_len) {
    parser_t ps = {
        .p = text,
        .end = text + len,
        .arena = arena,
        .errbuf = errbuf,
        .errbuf_len = errbuf_len,
        .failed = 0,
    };
    json_value_t *root = parse_value(&ps);
    if (ps.failed) return NULL;
    skip_ws(&ps);
    /* Trailing garbage is tolerated on purpose - bspwm's output is
     * always a single well-formed document and being strict here buys
     * us nothing but extra failure modes. */
    return root;
}

/* ------------------------------------------------------------ accessors */

json_value_t *json_object_get(const json_value_t *obj, const char *key) {
    if (!obj || obj->type != JT_OBJECT) return NULL;
    for (json_member_t *m = obj->u.object; m; m = m->next) {
        if (strcmp(m->key, key) == 0) return m->value;
    }
    return NULL;
}

const char *json_get_string(const json_value_t *v) {
    if (!v || v->type != JT_STRING) return NULL;
    return v->u.string;
}

int json_get_bool(const json_value_t *v, int default_val) {
    if (!v || v->type != JT_BOOL) return default_val;
    return v->u.boolean;
}

long long json_get_int(const json_value_t *v, long long default_val) {
    if (!v || v->type != JT_NUMBER) return default_val;
    return (long long)v->u.number;
}

int json_is_null(const json_value_t *v) {
    return v == NULL || v->type == JT_NULL;
}
