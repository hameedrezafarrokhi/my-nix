#ifndef BSPI_CONFIG_H
#define BSPI_CONFIG_H

#include <stddef.h>
#include "ini.h"
#include "ignore.h"

/* Desktops are numbered 1..20 within their monitor (the 1st desktop on
 * a monitor is "ws1", the 2nd is "ws2", and so on) for the purposes of
 * the `[workspaces...]` prefix sections - this is independent of
 * whatever bspwm's own desktop name/id happens to be, since bspi
 * overwrites the name anyway. */
#define WORKSPACE_PREFIX_MAX 20

/* Beyond the original catch-all `[workspaces]` section, a prefix can
 * be broken down by a desktop's state along two independent axes:
 * whether it currently has anything worth showing ("occupied", using
 * the same definition as the icon fallback - a sticky-only or
 * ignored-only desktop counts as unoccupied, same as a literally empty
 * one), and whether it's the desktop currently shown on its monitor
 * ("focused"). That's four sections:
 *
 *   [workspaces-occupied-focused]    occupied,   focused
 *   [workspaces-occupied]            occupied,   unfocused/idle
 *   [workspaces-unoccupied-focused]  unoccupied, focused
 *   [workspaces-unoccupied]          unoccupied, unfocused/idle
 *
 * See bspi_config_ws_prefix_for() for exactly how these combine with
 * each other and with the plain `[workspaces]` section. */
typedef enum {
    WS_CAT_OCCUPIED_FOCUSED = 0,
    WS_CAT_OCCUPIED_IDLE = 1,
    WS_CAT_EMPTY_FOCUSED = 2,
    WS_CAT_EMPTY_IDLE = 3,
    WS_CAT_COUNT = 4,
} ws_category_t;

typedef struct {
    icon_table_t icons;
    ignore_table_t ignore;

    /* 1-indexed; [0] is unused. NULL means "no prefix configured for
     * this position" - same effective result as an explicit empty
     * value. This is the original, undifferentiated `[workspaces]`
     * section. */
    char *ws_prefix[WORKSPACE_PREFIX_MAX + 1];

    /* Same shape, one array per state-specific section above. */
    char *ws_cat_prefix[WS_CAT_COUNT][WORKSPACE_PREFIX_MAX + 1];

    /* How many `wsN = ...` keys were seen under each state-specific
     * section (regardless of whether the value was empty) - this is
     * what determines whether a section counts as "defined" at all
     * for the fallback rules, independent of which specific positions
     * it happens to cover. */
    int ws_cat_defined_count[WS_CAT_COUNT];
} bspi_config_t;

/* Parses every recognized section of `path` in one pass:
 *
 *   [Icons]                          WM class -> icon glyph(s) (unchanged format)
 *   [Ignore]                         class/instance/title/all -> comma-separated glob patterns
 *   [Workspaces]                     ws1..ws20 -> prefix, used for every state
 *   [Workspaces-Occupied-Focused]    ws1..ws20 -> prefix, occupied + focused only
 *   [Workspaces-Occupied]            ws1..ws20 -> prefix, occupied + unfocused only
 *   [Workspaces-Unoccupied-Focused]  ws1..ws20 -> prefix, unoccupied + focused only
 *   [Workspaces-Unoccupied]          ws1..ws20 -> prefix, unoccupied + unfocused only
 *
 * Section names and option keys are matched case-insensitively.
 * Returns 0 on success, -1 if the file couldn't be opened/read at all
 * (errbuf gets a human-readable reason) - the one case bspi still
 * treats as a hard startup error. */
int bspi_config_load(bspi_config_t *cfg, const char *path, char *errbuf, size_t errbuf_len);

void bspi_config_free(bspi_config_t *cfg);

/* Resolves the prefix for 1-indexed workspace `ws_index` given its
 * current (occupied, focused) state. May return NULL (no prefix).
 *
 * Precedence:
 *
 *  1. If none of the four state-specific sections have any entries at
 *     all, the plain `[workspaces]` value for this position is used
 *     for every state (the original, single-tier behaviour - fully
 *     backwards compatible with configs that only ever set `[workspaces]`).
 *
 *  2. Else, if exactly one of the four state-specific sections has any
 *     entries, that section's value for this position is used for
 *     every state, taking over the role `[workspaces]` played in (1) -
 *     `[workspaces]` itself is not consulted in this case.
 *
 *  3. Else (two or more state-specific sections are in use): the
 *     section matching this exact state is used if it has a value for
 *     this position; if not, its same-occupancy opposite-focus
 *     counterpart is used instead (occupied-focused <-> occupied,
 *     unoccupied-focused <-> unoccupied) if *that* has a value; if
 *     still nothing, it falls back to the plain `[workspaces]` value
 *     for this position, same as case (1). */
const char *bspi_config_ws_prefix_for(const bspi_config_t *cfg, int ws_index,
                                       int occupied, int focused);

#endif /* BSPI_CONFIG_H */
