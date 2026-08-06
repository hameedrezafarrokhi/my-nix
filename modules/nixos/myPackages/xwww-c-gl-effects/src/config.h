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
    double bezier[4];        /* x1,y1,x2,y2 -- used when easing == EASE_CUSTOM_BEZIER */

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

    /* slideshow / daemon-style mode */
    char slideshow_dir[4096]; /* non-empty enables slideshow mode */
    double slideshow_interval; /* seconds between wallpaper changes */
    int    slideshow_shuffle;  /* 0 = sequential/alphabetical loop, 1 = random order */
    int    slideshow_daemonize; /* fork to background, write pidfile */
    int    slideshow_stop;      /* --slideshow-stop: kill a running daemonized slideshow */

    /* logo-sting: string paths live here (tparams_t stays numeric-only
     * plus one non-owning buf_t* set by main.c); LOGO_PATH may be a file
     * or a directory (random pick, same convention as the wallpaper
     * target). LOGO_SOUND is optional and played once via whichever of
     * paplay/aplay/ffplay/mpv is found on PATH, fire-and-forget. */
    char logo_path[4096];
    char logo_sound[4096];
} xwww_opts_t;

xwww_opts_t opts_defaults(void);

/* Load $HOME/.config/xwww/xwwwrc (or an explicit path) into opts,
 * overwriting only the *global* keys present in the file (keys inside a
 * "[effect-name]" section are skipped here -- see
 * config_apply_effect_section() below). Missing file is not an error. */
int config_load(xwww_opts_t *o, const char *explicit_path);

/* Re-reads the config file looking for a "[effect_name]" section and
 * applies just those keys on top of whatever's already in `o` (global
 * config + CLI flags). Call this once the active effect is known, right
 * before rendering. A config file might look like:
 *
 *   ANIMATION="fade"
 *   DURATION_MS=500
 *
 *   [wave]
 *   DURATION_MS=800
 *   WAVE_AMP=90
 *
 *   [circle-out]
 *   ORIGIN_X=100
 *   ORIGIN_Y=0
 *
 * No-op if no config file was loaded or the section doesn't exist. */
void config_apply_effect_section(xwww_opts_t *o, const char *effect_name);

/* Parse argv into opts, overriding whatever the config file set.
 * Returns 0 on success, -1 on a parse error (message already printed). */
int config_parse_args(xwww_opts_t *o, int argc, char **argv);

#endif
