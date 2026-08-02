#include "common.h"
#include "config.h"
#include "xapp.h"

#include <stdio.h>
#include <string.h>

/* Scans argv for -c/--config so we know which file to load *before* running
 * full CLI parsing (which then overrides whatever the file set). */
static const char *scan_for_config_flag(int argc, char **argv) {
    for (int i = 1; i < argc - 1; i++) {
        if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--config") == 0) {
            return argv[i + 1];
        }
    }
    return NULL;
}

int main(int argc, char **argv) {
    config_t cfg;
    config_set_defaults(&cfg);

    const char *config_path = scan_for_config_flag(argc, argv);
    if (!config_path) config_path = config_default_path();
    config_load_file(&cfg, config_path);

    if (!config_parse_args(&cfg, argc, argv)) {
        fprintf(stderr, "Try '%s --help' for usage.\n", argv[0]);
        return 2;
    }

    return xapp_run(&cfg);
}
