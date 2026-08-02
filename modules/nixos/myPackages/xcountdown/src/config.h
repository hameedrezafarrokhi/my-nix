#ifndef COUNTDOWN_CONFIG_H
#define COUNTDOWN_CONFIG_H

#include "common.h"

/* Fills cfg with built-in defaults. */
void config_set_defaults(config_t *cfg);

/* Loads key=value pairs from `path` on top of whatever is already in cfg.
 * Missing file is not an error (returns 1); malformed lines are skipped
 * with a warning on stderr. Returns 0 only on a fatal error. */
int config_load_file(config_t *cfg, const char *path);

/* Parses argv (after program name) on top of cfg, overriding anything set
 * by the config file. Returns 1 on success. On --help/--version, prints
 * and exits directly. On error, prints a message to stderr and returns 0. */
int config_parse_args(config_t *cfg, int argc, char **argv);

/* Returns the default config file path (~/.config/countdown/countdown.conf),
 * in a static buffer. */
const char *config_default_path(void);

/* Parses a binding string like "exit", "pause", "inc:60", "none" into a
 * binding_t. Returns 1 on success. */
int config_parse_binding(const char *str, binding_t *out);

#endif
