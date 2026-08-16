#ifndef BSPI_CONFIG_H
#define BSPI_CONFIG_H

#include <stddef.h>
#include "ini.h"
#include "ignore.h"

/* Desktops are numbered 1..20 within their monitor (the 1st desktop on
 * a monitor is "ws1", the 2nd is "ws2", and so on) for the purposes of
 * the `[workspaces]` prefix section - this is independent of whatever
 * bspwm's own desktop name/id happens to be, since bspi overwrites the
 * name anyway. */
#define WORKSPACE_PREFIX_MAX 20

typedef struct {
    icon_table_t icons;
    ignore_table_t ignore;
    /* 1-indexed; [0] is unused. NULL means "no prefix configured" -
     * same effective result as an explicit empty value. */
    char *ws_prefix[WORKSPACE_PREFIX_MAX + 1];
} bspi_config_t;

/* Parses every recognized section of `path` in one pass:
 *
 *   [Icons]       WM class -> icon glyph(s)          (unchanged format)
 *   [Ignore]      class/instance/title/all -> comma-separated glob patterns
 *   [Workspaces]  ws1..ws20 -> a prefix string (may be empty) prepended
 *                 to that positional desktop's computed icon name
 *
 * Section names and option keys are matched case-insensitively.
 * Returns 0 on success, -1 if the file couldn't be opened/read at all
 * (errbuf gets a human-readable reason) - the one case bspi still
 * treats as a hard startup error. */
int bspi_config_load(bspi_config_t *cfg, const char *path, char *errbuf, size_t errbuf_len);

void bspi_config_free(bspi_config_t *cfg);

/* Returns the configured prefix for 1-indexed workspace `ws_index`, or
 * NULL if none is configured / out of range. */
const char *bspi_config_ws_prefix(const bspi_config_t *cfg, int ws_index);

#endif /* BSPI_CONFIG_H */
