#ifndef XWWW_CONFIG_H
#define XWWW_CONFIG_H

#include "image.h"
#include "transitions.h"
#include "util.h"

typedef struct {
    /* target/image selection */
    char target[4096];       /* file or directory, as given on the CLI */

    /* transition timing */
    int    frames;           /* legacy-style frame count (used if duration_ms <= 0) */
    double duration_ms;      /* preferred: total transition length in ms */
    double fps_cap;          /* max frames per second, 0 = uncapped */
    easing_t easing;

    /* effect selection */
    char animation[64];
    char random_list[512];   /* comma separated, empty = pick from full table */
    int  use_random;

    /* image placement */
    scale_mode_t scale_mode;
    uint32_t bg_color;       /* 0xAARRGGBB, used by fit/center/tile padding */

    /* performance knobs */
    double render_scale;     /* 0 < x <= 1, downscale canvas during animation only */
    int    threads;          /* 0 = auto (num CPUs) */

    /* multi-monitor */
    char output[64];         /* "all" (default, span/whole root) or a monitor name */

    /* effect-specific */
    tparams_t tp;

    int list_only;
    int show_help;
    int show_version;
    int restore_mode;        /* re-set last wallpaper, no transition, no ~/.xwww-bg rewrite */
    int no_save;              /* don't write ~/.xwww-bg this run */
    char config_path[4096];
} xwww_opts_t;

xwww_opts_t opts_defaults(void);

/* Load $HOME/.config/xwww/xwwwrc (or an explicit path) into opts,
 * overwriting only the keys present in the file. Missing file is not
 * an error. Returns 0 on success (or "not found", which is fine). */
int config_load(xwww_opts_t *o, const char *explicit_path);

/* Parse argv into opts, overriding whatever the config file set.
 * Returns 0 on success, -1 on a parse error (message already printed). */
int config_parse_args(xwww_opts_t *o, int argc, char **argv);

#endif
