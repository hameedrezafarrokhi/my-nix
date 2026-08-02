#include "rescan.h"
#include "ipc.h"
#include "json.h"
#include "common.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_ICONS 4
#define CLASS_BUF_LEN 256
#define NAME_BUF_LEN 1024

typedef struct {
    char items[MAX_ICONS][CLASS_BUF_LEN];
    int count;
} class_list_t;

static void class_list_add(class_list_t *cl, const char *class_name) {
    if (!class_name || !*class_name) return;
    if (cl->count >= MAX_ICONS) return;
    for (int i = 0; i < cl->count; i++) {
        if (strcmp(cl->items[i], class_name) == 0) return; /* already have it */
    }
    snprintf(cl->items[cl->count], CLASS_BUF_LEN, "%s", class_name);
    cl->count++;
}

/* A node's own client class, falling back to a live WM_CLASS lookup
 * (via xclass) when bspwm reported an empty className - this mirrors
 * the Chromium-related workaround from the original script, but
 * without forking xprop, and correctly takes the *class* half of
 * WM_CLASS rather than the *instance* half (see xclass.h). */
static const char *node_own_class(const json_value_t *client, const json_value_t *node,
                                   xclass_ctx_t *xctx, char *scratch, size_t scratch_len) {
    const char *cls = json_get_string(json_object_get(client, "className"));
    if (cls && *cls) return cls;

    if (!xctx) return NULL;
    long long id = json_get_int(json_object_get(node, "id"), -1);
    if (id < 0) return NULL;
    return xclass_get(xctx, (uint32_t)id, scratch, scratch_len);
}

/* Recursively collects up to MAX_ICONS distinct, non-sticky,
 * non-ignored client classes from a desktop's node tree, in the same
 * left-to-right, first-seen order the original Python produced (see
 * the README for why a plain pre-order walk is exactly equivalent to
 * the original's "children first, self last" generator - only leaf
 * nodes ever carry a client in bspwm's tree, so the two orderings can
 * never actually differ in practice). Stops early once four unique
 * classes are found, which also saves needless X round-trips on
 * desktops with many windows. */
static void collect_classes(const json_value_t *node, xclass_ctx_t *xctx,
                             const ignore_table_t *ignore, class_list_t *cl) {
    if (cl->count >= MAX_ICONS || json_is_null(node)) return;

    int sticky = json_get_bool(json_object_get(node, "sticky"), 0);
    if (!sticky) {
        json_value_t *client = json_object_get(node, "client");
        if (!json_is_null(client)) {
            char scratch[CLASS_BUF_LEN];
            const char *cls = node_own_class(client, node, xctx, scratch, sizeof(scratch));
            const char *instance = json_get_string(json_object_get(client, "instanceName"));

            const char *title = NULL;
            char title_buf[CLASS_BUF_LEN];
            if (ignore_table_needs_title(ignore) && xctx) {
                long long id = json_get_int(json_object_get(node, "id"), -1);
                if (id >= 0) title = xclass_get_title(xctx, (uint32_t)id, title_buf, sizeof(title_buf));
            }

            if (!ignore_table_matches(ignore, cls, instance, title)) {
                class_list_add(cl, cls);
            }
        }
        if (cl->count >= MAX_ICONS) return;
    }

    collect_classes(json_object_get(node, "firstChild"), xctx, ignore, cl);
    if (cl->count >= MAX_ICONS) return;
    collect_classes(json_object_get(node, "secondChild"), xctx, ignore, cl);
}

/* Joins the icons for each collected class with a single space into
 * `out` (size out_len). Truncates gracefully rather than overflowing
 * if someone configures absurdly long icon strings. */
static void build_icon_string(const class_list_t *cl, const icon_table_t *icons,
                               char *out, size_t out_len) {
    size_t pos = 0;
    out[0] = '\0';
    for (int i = 0; i < cl->count; i++) {
        const char *icon = icon_table_lookup(icons, cl->items[i]);
        if (!icon) icon = "";

        if (i > 0 && pos + 1 < out_len) out[pos++] = ' ';
        size_t ilen = strlen(icon);
        if (pos + ilen >= out_len) ilen = out_len - pos - 1;
        memcpy(out + pos, icon, ilen);
        pos += ilen;
    }
    out[pos] = '\0';
}

static void rename_desktop(const char *sock_path, long long id, const char *name) {
    char id_str[32];
    snprintf(id_str, sizeof(id_str), "%lld", id);

    const char *argv[] = { "desktop", id_str, "--rename", name };
    char *resp = NULL;
    size_t resp_len = 0;
    char errbuf[256];

    if (bspwm_send(sock_path, argv, 4, &resp, &resp_len, errbuf, sizeof(errbuf)) != 0) {
        LOGW("failed to rename desktop %lld to '%s': %s", id, name, errbuf);
        return;
    }
    free(resp);
    LOGI("renamed desktop %lld -> '%s'", id, name);
}

static void process_desktop(const char *sock_path, const bspi_config_t *cfg,
                             xclass_ctx_t *xctx, const json_value_t *desktop, int ws_index) {
    long long id = json_get_int(json_object_get(desktop, "id"), -1);
    if (id < 0) {
        LOGW("skipping a desktop with no usable id in bspwm's output");
        return;
    }
    const char *current_name = json_get_string(json_object_get(desktop, "name"));
    if (!current_name) current_name = "";

    /* Collect non-sticky, non-ignored classes actually present on this
     * desktop right now. Note this can legitimately be empty even
     * when `root` isn't null: a desktop showing only a sticky window
     * (which bspwm transfers into whatever desktop is currently
     * focused on its monitor) or only ignored windows has *no*
     * "real" content of its own, and must fall back to the same
     * empty-desktop icon as a desktop with no windows at all.
     * Treating "no matching classes" and "no root" differently was
     * the bug: a focused, sticky-only desktop used to get renamed to
     * an *empty string* instead of the `_other` icon, which then made
     * bar modules that hide blank-named desktops appear to shift
     * every later desktop's label left by one. */
    class_list_t cl = { .count = 0 };
    json_value_t *root = json_object_get(desktop, "root");
    if (!json_is_null(root)) {
        collect_classes(root, xctx, &cfg->ignore, &cl);
    }

    char icons_part[NAME_BUF_LEN];
    if (cl.count == 0) {
        const char *other = icon_table_lookup(&cfg->icons, "_other");
        snprintf(icons_part, sizeof(icons_part), "%s", other ? other : "");
    } else {
        build_icon_string(&cl, &cfg->icons, icons_part, sizeof(icons_part));
    }

    const char *prefix = bspi_config_ws_prefix(cfg, ws_index);
    char new_name[NAME_BUF_LEN];
    if (prefix && *prefix) {
        if (icons_part[0] != '\0') {
            snprintf(new_name, sizeof(new_name), "%s %s", prefix, icons_part);
        } else {
            snprintf(new_name, sizeof(new_name), "%s", prefix);
        }
    } else {
        snprintf(new_name, sizeof(new_name), "%s", icons_part);
    }

    if (strcmp(current_name, new_name) != 0) {
        rename_desktop(sock_path, id, new_name);
    }
}

int bspi_rescan(const char *sock_path, const bspi_config_t *cfg, xclass_ctx_t *xctx) {
    char *data = NULL;
    size_t data_len = 0;
    char errbuf[256];

    const char *argv[] = { "wm", "-d" };
    if (bspwm_send(sock_path, argv, 2, &data, &data_len, errbuf, sizeof(errbuf)) != 0) {
        LOGW("could not query bspwm state: %s", errbuf);
        return -1;
    }

    json_arena_t arena;
    json_arena_init(&arena);

    char jerr[128];
    json_value_t *root = json_parse(data, data_len, &arena, jerr, sizeof(jerr));
    free(data);

    if (!root) {
        LOGW("could not parse bspwm's state (%s) - skipping this rescan", jerr);
        json_arena_free(&arena);
        return 0; /* transient/cosmetic - don't treat as a hard failure */
    }

    json_value_t *monitors = json_object_get(root, "monitors");
    if (!monitors || monitors->type != JT_ARRAY) {
        LOGW("bspwm's state had no usable 'monitors' array - skipping this rescan");
        json_arena_free(&arena);
        return 0;
    }

    for (json_value_t *mon = monitors->array_head; mon; mon = mon->next) {
        json_value_t *desktops = json_object_get(mon, "desktops");
        if (!desktops || desktops->type != JT_ARRAY) continue;
        int ws_index = 0;
        for (json_value_t *desk = desktops->array_head; desk; desk = desk->next) {
            ws_index++;
            process_desktop(sock_path, cfg, xctx, desk, ws_index);
        }
    }

    json_arena_free(&arena);
    return 0;
}
