/*
 * bspborder — per-window border colors for bspwm.
 *
 * Talks to the bspwm socket directly (no bspc/jq/xprop/awk/sed forks) and
 * queries X11 properties via Xlib in-process. Node state (sticky, private,
 * locked, marked, tiling state) is cached locally and kept up to date by
 * listening to node_state/node_flag events, so the hot path (node_focus)
 * never has to round-trip a JSON tree query through bspwm.
 *
 * Build:  make
 * Run:    bspborder [-c /path/to/config]
 * Usually started from bspwmrc:  bspborder &
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>
#include <regex.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>

/* ------------------------------------------------------------------ */
/* Config / limits                                                     */
/* ------------------------------------------------------------------ */

#define MAX_RULES     512
#define MAX_CONDS     8
#define COLOR_LEN     16
#define FIELD_LEN     192
#define LINE_MAX_LEN  1024
#define MAX_TOKENS    32
#define CACHE_BUCKETS 4096  /* power of two */

static const char *default_conf_relpath = "/bspborder/bspborder.conf";

/* ------------------------------------------------------------------ */
/* Small helpers                                                       */
/* ------------------------------------------------------------------ */

static void die(const char *msg) {
    fprintf(stderr, "bspborder: %s\n", msg);
    exit(1);
}

static int looks_like_hex_id(const char *s) {
    if (!s || s[0] != '0' || s[1] != 'x' || s[2] == '\0') return 0;
    for (const char *p = s + 2; *p; p++)
        if (!isxdigit((unsigned char)*p)) return 0;
    return 1;
}

/* ------------------------------------------------------------------ */
/* bspwm socket protocol                                               */
/* ------------------------------------------------------------------ */

static char g_socket_path[256];

/* Reproduce bspwm's default socket path algorithm when BSPWM_SOCKET
 * isn't set: /tmp/bspwm<host>_<display>_<screen>-socket, derived from
 * $DISPLAY (e.g. ":1.0" -> host="", display=1, screen=0). */
static void compute_default_socket_path(char *out, size_t outsz) {
    const char *disp = getenv("DISPLAY");
    char host[128] = "";
    int dn = 0, sn = 0;
    if (disp && *disp) {
        const char *colon = strchr(disp, ':');
        if (colon) {
            size_t hlen = (size_t)(colon - disp);
            if (hlen >= sizeof(host)) hlen = sizeof(host) - 1;
            memcpy(host, disp, hlen);
            host[hlen] = '\0';
            dn = atoi(colon + 1);
            const char *dot = strchr(colon + 1, '.');
            if (dot) sn = atoi(dot + 1);
        }
    }
    snprintf(out, outsz, "/tmp/bspwm%s_%d_%d-socket", host, dn, sn);
}

static void resolve_socket_path(void) {
    const char *env = getenv("BSPWM_SOCKET");
    if (env && *env) {
        snprintf(g_socket_path, sizeof(g_socket_path), "%s", env);
    } else {
        compute_default_socket_path(g_socket_path, sizeof(g_socket_path));
    }
}

static int bspwm_connect(void) {
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) return -1;
    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    size_t pathlen = strlen(g_socket_path);
    if (pathlen >= sizeof(addr.sun_path)) pathlen = sizeof(addr.sun_path) - 1;
    memcpy(addr.sun_path, g_socket_path, pathlen);
    addr.sun_path[pathlen] = '\0';
    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
        close(fd);
        return -1;
    }
    return fd;
}

/* Write argv as a NUL-separated bspwm message on fd. */
static int bspwm_write_msg(int fd, char **argv, int argc) {
    char buf[4096];
    size_t off = 0;
    for (int i = 0; i < argc; i++) {
        size_t l = strlen(argv[i]) + 1; /* include NUL */
        if (off + l > sizeof(buf)) return -1;
        memcpy(buf + off, argv[i], l);
        off += l;
    }
    ssize_t n = send(fd, buf, off, 0);
    return (n == (ssize_t)off) ? 0 : -1;
}

/* Read the full response until EOF into a malloc'd, NUL-terminated buffer. */
static char *bspwm_read_all(int fd) {
    size_t cap = 4096, len = 0;
    char *resp = malloc(cap);
    if (!resp) return NULL;
    char rbuf[4096];
    ssize_t n;
    while ((n = recv(fd, rbuf, sizeof(rbuf), 0)) > 0) {
        if (len + (size_t)n + 1 > cap) {
            cap = (len + (size_t)n + 1) * 2;
            char *tmp = realloc(resp, cap);
            if (!tmp) { free(resp); return NULL; }
            resp = tmp;
        }
        memcpy(resp + len, rbuf, n);
        len += (size_t)n;
    }
    resp[len] = '\0';
    return resp;
}

/* One-shot command: connect, send, read full response, disconnect.
 * response_out may be NULL if the caller doesn't care. */
static int bspwm_command(char **argv, int argc, char **response_out) {
    int fd = bspwm_connect();
    if (fd < 0) return -1;
    int rc = bspwm_write_msg(fd, argv, argc);
    if (rc == 0 && response_out) {
        *response_out = bspwm_read_all(fd);
    }
    close(fd);
    return rc;
}

/* ------------------------------------------------------------------ */
/* Line-buffered reader for the persistent subscribe connection        */
/* ------------------------------------------------------------------ */

typedef struct {
    char buf[8192];
    size_t len;
} LineReader;

/* Blocks until a full line is available, EOF, or error. Returns 1 with
 * `out` filled (no trailing newline) on success, 0 on EOF/error. */
static int read_line(int fd, LineReader *lr, char *out, size_t outsz) {
    for (;;) {
        char *nl = memchr(lr->buf, '\n', lr->len);
        if (nl) {
            size_t linelen = (size_t)(nl - lr->buf);
            size_t copy = linelen < outsz - 1 ? linelen : outsz - 1;
            memcpy(out, lr->buf, copy);
            out[copy] = '\0';
            size_t consumed = linelen + 1;
            memmove(lr->buf, lr->buf + consumed, lr->len - consumed);
            lr->len -= consumed;
            return 1;
        }
        if (lr->len >= sizeof(lr->buf)) {
            /* pathological over-long line: drop it and keep going */
            lr->len = 0;
        }
        ssize_t n = recv(fd, lr->buf + lr->len, sizeof(lr->buf) - lr->len, 0);
        if (n <= 0) return 0;
        lr->len += (size_t)n;
    }
}

/* ------------------------------------------------------------------ */
/* Tiny tokenizer (whitespace-separated, no quoting needed for events) */
/* ------------------------------------------------------------------ */

static int tokenize_ws(char *line, char *tokens[], int max) {
    int n = 0;
    char *save = NULL;
    char *tok = strtok_r(line, " \t", &save);
    while (tok && n < max) {
        tokens[n++] = tok;
        tok = strtok_r(NULL, " \t", &save);
    }
    return n;
}

/* ------------------------------------------------------------------ */
/* Minimal JSON scanning (only used for the infrequent per-node query) */
/* ------------------------------------------------------------------ */

static int json_find_bool(const char *json, const char *key, int *out) {
    char pat[64];
    snprintf(pat, sizeof(pat), "\"%s\":", key);
    const char *p = strstr(json, pat);
    if (!p) return 0;
    p += strlen(pat);
    while (*p == ' ') p++;
    *out = (strncmp(p, "true", 4) == 0);
    return 1;
}

static int json_find_string(const char *json, const char *key, char *out, size_t outsz) {
    char pat[64];
    snprintf(pat, sizeof(pat), "\"%s\":", key);
    const char *p = strstr(json, pat);
    if (!p) return 0;
    p += strlen(pat);
    while (*p == ' ') p++;
    if (*p == '"') {
        p++;
        size_t i = 0;
        while (*p && *p != '"' && i < outsz - 1) out[i++] = *p++;
        out[i] = '\0';
        return 1;
    }
    if (strncmp(p, "null", 4) == 0) { out[0] = '\0'; return 1; }
    return 0;
}

/* ------------------------------------------------------------------ */
/* Node cache: node id -> tiling state + sticky/private/locked/marked  */
/* ------------------------------------------------------------------ */

typedef struct {
    unsigned long id;
    char state[16];   /* "tiled" | "floating" | "fullscreen" | "pseudo_tiled" */
    int sticky, priv, locked, marked;
    int used;
} NodeInfo;

static NodeInfo g_cache[CACHE_BUCKETS];

static size_t cache_slot(unsigned long id) {
    /* Fibonacci hashing over the bucket count. */
    unsigned long h = id * 2654435761UL;
    return (h >> 16) & (CACHE_BUCKETS - 1);
}

static NodeInfo *cache_lookup(unsigned long id, int create) {
    size_t start = cache_slot(id);
    for (size_t i = 0; i < CACHE_BUCKETS; i++) {
        size_t idx = (start + i) & (CACHE_BUCKETS - 1);
        NodeInfo *e = &g_cache[idx];
        if (e->used && e->id == id) return e;
        if (!e->used) {
            if (!create) return NULL;
            e->used = 1;
            e->id = id;
            strcpy(e->state, "tiled");
            e->sticky = e->priv = e->locked = e->marked = 0;
            return e;
        }
    }
    return NULL; /* cache full — extremely unlikely at 4096 buckets */
}

static void cache_remove(unsigned long id) {
    size_t start = cache_slot(id);
    for (size_t i = 0; i < CACHE_BUCKETS; i++) {
        size_t idx = (start + i) & (CACHE_BUCKETS - 1);
        NodeInfo *e = &g_cache[idx];
        if (!e->used) return;
        if (e->id == id) { e->used = 0; return; }
    }
}

/* Populate/refresh a cache entry from bspwm (used on node_add and as a
 * lazy fallback for windows that existed before bspborder started). */
static void cache_refresh(unsigned long id) {
    char idbuf[32];
    snprintf(idbuf, sizeof(idbuf), "0x%lx", id);
    char *argv[] = {"query", "-T", "-n", idbuf};
    char *resp = NULL;
    if (bspwm_command(argv, 4, &resp) != 0 || !resp) { free(resp); return; }

    NodeInfo *e = cache_lookup(id, 1);
    if (e) {
        int b;
        if (json_find_bool(resp, "sticky", &b)) e->sticky = b;
        if (json_find_bool(resp, "private", &b)) e->priv = b;
        if (json_find_bool(resp, "locked", &b)) e->locked = b;
        if (json_find_bool(resp, "marked", &b)) e->marked = b;
        char state[16];
        if (json_find_string(resp, "state", state, sizeof(state)) && state[0])
            snprintf(e->state, sizeof(e->state), "%s", state);
    }
    free(resp);
}

/* ------------------------------------------------------------------ */
/* X11 property lookups (in-process, no xprop)                         */
/* ------------------------------------------------------------------ */

static Display *g_dpy;
static Atom A_NET_WM_NAME, A_UTF8_STRING, A_NET_WM_WINDOW_TYPE;

/* A window can be destroyed between us reading a node_focus/node_add event
 * for it and us actually querying its X properties -- this happens for
 * real with very short-lived popups/dialogs. Xlib's *default* error
 * handler treats a resulting BadWindow (or similar) as fatal and calls
 * exit(), silently killing the whole daemon and leaving the last-applied
 * border color stuck forever. Install a handler that just ignores errors
 * instead; the next legitimate node_focus event will self-correct the
 * color anyway. */
static int x_error_handler(Display *d, XErrorEvent *e) {
    (void)d; (void)e;
    return 0;
}

static void x11_init(void) {
    g_dpy = XOpenDisplay(NULL);
    if (!g_dpy) die("cannot open X display (is DISPLAY set?)");
    XSetErrorHandler(x_error_handler);
    A_NET_WM_NAME = XInternAtom(g_dpy, "_NET_WM_NAME", False);
    A_UTF8_STRING = XInternAtom(g_dpy, "UTF8_STRING", False);
    A_NET_WM_WINDOW_TYPE = XInternAtom(g_dpy, "_NET_WM_WINDOW_TYPE", False);
}

static void get_class_instance(Window w, char *cls, size_t clssz,
                                char *inst, size_t instsz) {
    cls[0] = '\0'; inst[0] = '\0';
    XClassHint hint;
    if (XGetClassHint(g_dpy, w, &hint)) {
        if (hint.res_class) { snprintf(cls, clssz, "%s", hint.res_class); XFree(hint.res_class); }
        if (hint.res_name)  { snprintf(inst, instsz, "%s", hint.res_name); XFree(hint.res_name); }
    }
}

static void get_title(Window w, char *out, size_t outsz) {
    out[0] = '\0';
    Atom type; int fmt; unsigned long nitems, bytes_after;
    unsigned char *data = NULL;

    if (XGetWindowProperty(g_dpy, w, A_NET_WM_NAME, 0, 1024, False,
                            A_UTF8_STRING, &type, &fmt, &nitems, &bytes_after,
                            &data) == Success && data) {
        snprintf(out, outsz, "%s", (char *)data);
        XFree(data);
        if (out[0]) return;
    }
    /* fall back to WM_NAME */
    char *name = NULL;
    if (XFetchName(g_dpy, w, &name) && name) {
        snprintf(out, outsz, "%s", name);
        XFree(name);
    }
}

static void get_window_type(Window w, char *out, size_t outsz) {
    out[0] = '\0';
    Atom type; int fmt; unsigned long nitems, bytes_after;
    unsigned char *data = NULL;
    if (XGetWindowProperty(g_dpy, w, A_NET_WM_WINDOW_TYPE, 0, 1, False,
                            XA_ATOM, &type, &fmt, &nitems, &bytes_after,
                            &data) == Success && data && nitems > 0) {
        Atom first = *(Atom *)data;
        XFree(data);
        char *name = XGetAtomName(g_dpy, first);
        if (name) {
            const char *prefix = "_NET_WM_WINDOW_TYPE_";
            const char *p = strncmp(name, prefix, strlen(prefix)) == 0
                                 ? name + strlen(prefix)
                                 : name;
            snprintf(out, outsz, "%s", p);
            XFree(name);
        }
    } else if (data) {
        XFree(data);
    }
}

/* ------------------------------------------------------------------ */
/* Config: rules engine                                                */
/* ------------------------------------------------------------------ */

typedef enum { M_CLASS, M_INSTANCE, M_TITLE, M_STATE, M_FLAG, M_TYPE } MatchKind;

typedef struct {
    MatchKind kind;
    char value[FIELD_LEN];
    int is_regex;
    regex_t re;
} Condition;

typedef struct {
    Condition conds[MAX_CONDS];
    int n_conds;
    char color[COLOR_LEN];
    int stop;
} Rule;

typedef struct {
    Rule rules[MAX_RULES];
    int n_rules;
    char default_color[COLOR_LEN];
} Config;

static Config g_cfg;

typedef struct {
    char class_[FIELD_LEN];
    char instance[FIELD_LEN];
    char title[256];
    char state[16];
    char wtype[64];
    int sticky, priv, locked, marked;
} WindowInfo;

static int str_matches(const Condition *c, const char *val) {
    if (!val) val = "";
    if (c->is_regex) return regexec(&c->re, val, 0, NULL, 0) == 0;
    return strcmp(c->value, val) == 0;
}

static int condition_matches(const Condition *c, const WindowInfo *wi) {
    switch (c->kind) {
        case M_CLASS:    return str_matches(c, wi->class_);
        case M_INSTANCE: return str_matches(c, wi->instance);
        case M_TITLE:
            if (c->is_regex) return regexec(&c->re, wi->title, 0, NULL, 0) == 0;
            return strstr(wi->title, c->value) != NULL; /* substring match */
        case M_STATE:    return strcmp(c->value, wi->state) == 0;
        case M_TYPE:     return strcasecmp(c->value, wi->wtype) == 0;
        case M_FLAG:
            if (strcmp(c->value, "sticky") == 0)  return wi->sticky;
            if (strcmp(c->value, "private") == 0) return wi->priv;
            if (strcmp(c->value, "locked") == 0)  return wi->locked;
            if (strcmp(c->value, "marked") == 0)  return wi->marked;
            return 0;
    }
    return 0;
}

static int rule_matches(const Rule *r, const WindowInfo *wi) {
    for (int i = 0; i < r->n_conds; i++)
        if (!condition_matches(&r->conds[i], wi)) return 0;
    return 1;
}

/* Evaluate rules top-to-bottom; later matches override earlier ones
 * (cascading, same semantics as the original shell `case` chain), unless
 * a rule sets `stop`, which halts evaluation immediately. */
static const char *resolve_color(const WindowInfo *wi) {
    static char color[COLOR_LEN];
    snprintf(color, sizeof(color), "%s", g_cfg.default_color);
    for (int i = 0; i < g_cfg.n_rules; i++) {
        Rule *r = &g_cfg.rules[i];
        if (rule_matches(r, wi)) {
            snprintf(color, sizeof(color), "%s", r->color);
            if (r->stop) break;
        }
    }
    return color;
}

/* ------------------------------------------------------------------ */
/* Config file parsing                                                 */
/* ------------------------------------------------------------------ */

static char *trim(char *s) {
    while (isspace((unsigned char)*s)) s++;
    if (*s == '\0') return s;
    char *end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) *end-- = '\0';
    return s;
}

/* Tokenize a config line, honoring "double quoted spans" as one token. */
static int tokenize_cfg(char *line, char *tokens[], int max) {
    int n = 0;
    char *p = line;
    while (*p && n < max) {
        while (isspace((unsigned char)*p)) p++;
        if (!*p) break;
        if (*p == '"') {
            p++;
            tokens[n++] = p;
            while (*p && *p != '"') p++;
            if (*p == '"') *p++ = '\0';
        } else {
            tokens[n++] = p;
            while (*p && !isspace((unsigned char)*p)) p++;
            if (*p) *p++ = '\0';
        }
    }
    return n;
}

static MatchKind kind_from_key(const char *key, int *ok) {
    *ok = 1;
    if (strcmp(key, "class") == 0)    return M_CLASS;
    if (strcmp(key, "instance") == 0) return M_INSTANCE;
    if (strcmp(key, "title") == 0)    return M_TITLE;
    if (strcmp(key, "state") == 0)    return M_STATE;
    if (strcmp(key, "flag") == 0)     return M_FLAG;
    if (strcmp(key, "type") == 0)     return M_TYPE;
    *ok = 0;
    return M_CLASS;
}

static void parse_rule_line(char *tokens[], int n) {
    if (g_cfg.n_rules >= MAX_RULES) {
        fprintf(stderr, "bspborder: too many rules, ignoring extra\n");
        return;
    }
    Rule *r = &g_cfg.rules[g_cfg.n_rules];
    memset(r, 0, sizeof(*r));

    for (int i = 1; i < n; i++) {
        char *tok = tokens[i];
        if (strcmp(tok, "stop") == 0) { r->stop = 1; continue; }

        char *eq = strchr(tok, '=');
        if (!eq) { fprintf(stderr, "bspborder: skipping malformed token '%s'\n", tok); continue; }
        *eq = '\0';
        char *key = tok;
        char *val = eq + 1;

        int is_regex = 0;
        size_t klen = strlen(key);
        if (klen > 0 && key[klen - 1] == '~') { is_regex = 1; key[klen - 1] = '\0'; }

        if (strcmp(key, "color") == 0) {
            snprintf(r->color, sizeof(r->color), "%s", val);
            continue;
        }

        int ok;
        MatchKind kind = kind_from_key(key, &ok);
        if (!ok) { fprintf(stderr, "bspborder: unknown condition key '%s'\n", key); continue; }

        if (r->n_conds >= MAX_CONDS) { fprintf(stderr, "bspborder: too many conditions on one rule\n"); continue; }
        Condition *c = &r->conds[r->n_conds++];
        c->kind = kind;
        c->is_regex = is_regex;
        snprintf(c->value, sizeof(c->value), "%s", val);
        if (is_regex) {
            if (regcomp(&c->re, val, REG_EXTENDED | REG_NOSUB) != 0) {
                fprintf(stderr, "bspborder: bad regex '%s', treating as literal\n", val);
                c->is_regex = 0;
            }
        }
    }

    if (r->color[0] == '\0') {
        fprintf(stderr, "bspborder: rule with no color=, ignoring\n");
        return;
    }
    g_cfg.n_rules++;
}

/* Mirrors the original script's:
 *   grep focused_border_color "$HOME/.bsp_conf_color" | awk -F'"' '{print $2}'
 * Only ever called at config-load time (startup / SIGHUP reload), never
 * per-event, since this file changes rarely (e.g. a colorscheme switcher)
 * and re-reading it on every focus change would defeat the whole point of
 * this rewrite. When present, it overrides the config's `default` color. */
static void apply_external_default_override(void) {
    const char *home = getenv("HOME");
    if (!home) return;
    char path[512];
    snprintf(path, sizeof(path), "%s/.bsp_conf_color", home);
    FILE *f = fopen(path, "r");
    if (!f) return;

    char line[512];
    while (fgets(line, sizeof(line), f)) {
        char *p = strstr(line, "focused_border_color");
        if (!p) continue;
        char *q1 = strchr(p, '"');
        if (!q1) continue;
        char *q2 = strchr(q1 + 1, '"');
        if (!q2) continue;
        size_t len = (size_t)(q2 - (q1 + 1));
        if (len >= sizeof(g_cfg.default_color)) len = sizeof(g_cfg.default_color) - 1;
        memcpy(g_cfg.default_color, q1 + 1, len);
        g_cfg.default_color[len] = '\0';
        fprintf(stderr, "bspborder: default color overridden by %s (%s)\n",
                path, g_cfg.default_color);
        break;
    }
    fclose(f);
}

static void load_config(const char *path) {
    memset(&g_cfg, 0, sizeof(g_cfg));
    snprintf(g_cfg.default_color, sizeof(g_cfg.default_color), "#7dc4e4");

    FILE *f = fopen(path, "r");
    if (!f) {
        fprintf(stderr, "bspborder: no config at %s, using built-in default color only\n", path);
        return;
    }

    char line[LINE_MAX_LEN];
    while (fgets(line, sizeof(line), f)) {
        char *s = trim(line);
        if (*s == '\0' || *s == '#') continue;

        char linecopy[LINE_MAX_LEN];
        snprintf(linecopy, sizeof(linecopy), "%s", s);
        char *tokens[MAX_TOKENS];
        int n = tokenize_cfg(linecopy, tokens, MAX_TOKENS);
        if (n == 0) continue;

        if (strcmp(tokens[0], "default") == 0 && n >= 2) {
            snprintf(g_cfg.default_color, sizeof(g_cfg.default_color), "%s", tokens[1]);
        } else if (strcmp(tokens[0], "rule") == 0) {
            parse_rule_line(tokens, n);
        } else {
            fprintf(stderr, "bspborder: ignoring unrecognized line: %s\n", s);
        }
    }
    fclose(f);
    apply_external_default_override();
    fprintf(stderr, "bspborder: loaded %d rule(s) from %s\n", g_cfg.n_rules, path);
}

static char g_config_path[512];

static void reload_config(int signum) {
    (void)signum;
    load_config(g_config_path);
}

/* ------------------------------------------------------------------ */
/* Applying the color                                                   */
/* ------------------------------------------------------------------ */

static char g_last_color[COLOR_LEN] = "";

static void apply_color(const char *color) {
    if (g_last_color[0] && strcmp(g_last_color, color) == 0) return; /* no-op, skip socket write */
    char *argv[] = {"config", "focused_border_color", (char *)color};
    bspwm_command(argv, 3, NULL);
    snprintf(g_last_color, sizeof(g_last_color), "%s", color);
}

/* ------------------------------------------------------------------ */
/* Event handling                                                       */
/* ------------------------------------------------------------------ */

/* Find the node id in an event line: the LAST token matching 0x[hex]+.
 * This is robust across bspwm versions/field-count differences instead
 * of hardcoding a column position. */
static unsigned long extract_node_id(char **tokens, int n, int *idx_out) {
    for (int i = n - 1; i >= 0; i--) {
        if (looks_like_hex_id(tokens[i])) {
            if (idx_out) *idx_out = i;
            return strtoul(tokens[i], NULL, 0);
        }
    }
    if (idx_out) *idx_out = -1;
    return 0;
}

static void handle_focus(unsigned long id) {
    NodeInfo *e = cache_lookup(id, 0);
    if (!e) { cache_refresh(id); e = cache_lookup(id, 0); }

    WindowInfo wi;
    memset(&wi, 0, sizeof(wi));
    get_class_instance((Window)id, wi.class_, sizeof(wi.class_), wi.instance, sizeof(wi.instance));
    get_title((Window)id, wi.title, sizeof(wi.title));
    get_window_type((Window)id, wi.wtype, sizeof(wi.wtype));
    if (e) {
        snprintf(wi.state, sizeof(wi.state), "%s", e->state);
        wi.sticky = e->sticky; wi.priv = e->priv; wi.locked = e->locked; wi.marked = e->marked;
    } else {
        snprintf(wi.state, sizeof(wi.state), "tiled");
    }

    apply_color(resolve_color(&wi));
}

static void handle_add(unsigned long id) {
    cache_refresh(id);
}

static void handle_remove(unsigned long id) {
    cache_remove(id);
}

static void handle_state(char **tokens, int node_idx, int n) {
    if (node_idx < 0 || node_idx + 2 >= n) return;
    unsigned long id = strtoul(tokens[node_idx], NULL, 0);
    const char *state_name = tokens[node_idx + 1];
    const char *status = tokens[node_idx + 2];
    if (strcmp(status, "on") != 0) return;
    NodeInfo *e = cache_lookup(id, 1);
    snprintf(e->state, sizeof(e->state), "%s", state_name);
}

static void handle_flag(char **tokens, int node_idx, int n) {
    if (node_idx < 0 || node_idx + 2 >= n) return;
    unsigned long id = strtoul(tokens[node_idx], NULL, 0);
    const char *flag_name = tokens[node_idx + 1];
    const char *status = tokens[node_idx + 2];
    int on = (strcmp(status, "on") == 0);
    NodeInfo *e = cache_lookup(id, 1);
    if (strcmp(flag_name, "sticky") == 0) e->sticky = on;
    else if (strcmp(flag_name, "private") == 0) e->priv = on;
    else if (strcmp(flag_name, "locked") == 0) e->locked = on;
    else if (strcmp(flag_name, "marked") == 0) e->marked = on;
}

/* ------------------------------------------------------------------ */
/* main                                                                  */
/* ------------------------------------------------------------------ */

static void build_default_config_path(char *out, size_t outsz) {
    const char *xdg = getenv("XDG_CONFIG_HOME");
    if (xdg && *xdg) {
        snprintf(out, outsz, "%s%s", xdg, default_conf_relpath);
        return;
    }
    const char *home = getenv("HOME");
    snprintf(out, outsz, "%s/.config%s", home ? home : "", default_conf_relpath);
}

int main(int argc, char **argv) {
    build_default_config_path(g_config_path, sizeof(g_config_path));
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-c") == 0 && i + 1 < argc) {
            snprintf(g_config_path, sizeof(g_config_path), "%s", argv[++i]);
        } else {
            fprintf(stderr, "usage: %s [-c config_path]\n", argv[0]);
            return 1;
        }
    }

    resolve_socket_path();
    x11_init();
    load_config(g_config_path);
    signal(SIGHUP, reload_config); /* live reload: kill -HUP <pid> */

    int sub_fd = bspwm_connect();
    if (sub_fd < 0) die("could not connect to bspwm socket");
    char *sub_argv[] = {"subscribe", "node_add", "node_remove", "node_focus", "node_state", "node_flag"};
    if (bspwm_write_msg(sub_fd, sub_argv, 6) != 0) die("could not send subscribe request");

    LineReader lr = {0};
    char line[LINE_MAX_LEN];

    while (read_line(sub_fd, &lr, line, sizeof(line))) {
        char *tokens[MAX_TOKENS];
        int n = tokenize_ws(line, tokens, MAX_TOKENS);
        if (n == 0) continue;

        const char *event = tokens[0];
        int idx;
        unsigned long id = extract_node_id(tokens, n, &idx);
        if (idx < 0) continue;

        if (strcmp(event, "node_focus") == 0) {
            handle_focus(id);
        } else if (strcmp(event, "node_add") == 0) {
            handle_add(id);
        } else if (strcmp(event, "node_remove") == 0) {
            handle_remove(id);
        } else if (strcmp(event, "node_state") == 0) {
            handle_state(tokens, idx, n);
        } else if (strcmp(event, "node_flag") == 0) {
            handle_flag(tokens, idx, n);
        }
    }

    fprintf(stderr, "bspborder: bspwm subscribe connection closed, exiting\n");
    close(sub_fd);
    XCloseDisplay(g_dpy);
    return 0;
}
