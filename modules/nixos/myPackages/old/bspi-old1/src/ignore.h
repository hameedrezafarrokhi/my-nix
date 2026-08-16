#ifndef BSPI_IGNORE_H
#define BSPI_IGNORE_H

/*
 * The `[ignore]` section of bspi.ini lets you exclude specific windows
 * from ever contributing an icon to a desktop's name - useful for
 * floating utility windows (picture-in-picture players, meeting
 * toolbars, etc.) that you don't want dominating the display.
 *
 *   [ignore]
 *   class    = Zoom, Peek
 *   instance = tmux-256color
 *   title    = Picture-in-Picture, Save File
 *   all      = Volume Control*
 *
 * - `class` matches the WM_CLASS *class* component (the same value
 *   used for icon lookups, e.g. "Firefox").
 * - `instance` matches the WM_CLASS *instance* component (the first,
 *   often-lowercase value, e.g. "firefox" vs the class "Firefox").
 * - `title` matches the window's title (_NET_WM_NAME/WM_NAME). Titles
 *   are only ever fetched from X if this list (or `all`) is non-empty,
 *   since it's an extra round-trip nothing else needs.
 * - `all` matches against class OR instance OR title - a catch-all
 *   when you don't care which field matches.
 *
 * Each value is a comma-separated list of glob patterns (`*`/`?`
 * wildcards work, matching is case-insensitive); a plain string with
 * no wildcard just has to match exactly.
 */

typedef struct {
    char **items;
    int count;
    int cap;
} bspi_str_list_t;

typedef struct {
    bspi_str_list_t class_patterns;
    bspi_str_list_t instance_patterns;
    bspi_str_list_t title_patterns;
    bspi_str_list_t any_patterns;
} ignore_table_t;

void ignore_table_init(ignore_table_t *t);
void ignore_table_free(ignore_table_t *t);

/* Adds a comma-separated list of patterns under one of the four keys
 * above ("class", "instance", "title", "all" - case doesn't matter).
 * Unrecognized keys are ignored rather than treated as an error. */
void ignore_table_add(ignore_table_t *t, const char *key, const char *csv_value);

/* True if any `title`/`all` patterns are configured - lets the caller
 * skip fetching a window's title from X when nothing would use it. */
int ignore_table_needs_title(const ignore_table_t *t);

/* True if this window should be excluded from naming. `title` may be
 * NULL (e.g. not fetched, or fetch failed) - title patterns simply
 * won't match in that case. */
int ignore_table_matches(const ignore_table_t *t, const char *class_name,
                          const char *instance_name, const char *title);

#endif /* BSPI_IGNORE_H */
