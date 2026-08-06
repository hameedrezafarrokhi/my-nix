#ifndef XWWW_TRANSITIONS_H
#define XWWW_TRANSITIONS_H

#include "buffer.h"
#include "util.h"

typedef struct {
    double wave_amp;       /* pixels */
    double wave_length;    /* pixels */
    int    pixelate_size;  /* max block size, pixels */
    int    blinds_count;   /* number of stripes (also used by stripes-* and panes-*) */
    int    checker_size;   /* pixels per checker cell */
    double seed;           /* per-run random seed in [0,1) -- drives every effect's randomness */

    /* origin point for circle-in/out, grow-center, diamond, clock,
     * fire-burst, bubbles -- percentages of canvas width/height, 0,0 =
     * top-left, 100,100 = bottom-right, 50,50 (default) = center. */
    double origin_x_pct;
    double origin_y_pct;

    double oblique_angle;  /* degrees, sweep direction for oblique-*, stripes-oblique-*, default 45 */
    double curl_pct;       /* 0-100, roll-cylinder radius for roll-away/carpet and
                             * curl-highlight width for page-turn, as % of canvas size */

    /* shatter */
    int    shard_size;     /* pixels, average irregular-piece size */

    /* fire-burst (the realistic multi-patch burn) */
    int    burn_patches;      /* number of independent burning patches, default 10 */
    double burn_jaggedness;   /* 0-1, how irregular the patch edges are, default 0.5 */

    /* half-swing */
    double pivot_pct;      /* 0-100, custom hinge position along the swing axis, default 50 */

    /* spinning cube / axis-spin */
    double cube_zoom;       /* 0-1, how far the cube shrinks mid-spin, default 0.3 */
    double cube_spin_speed; /* extra full rotations before settling, default 1.5 */
    int    axisspin_vertical; /* 0 = spin around a vertical axis (horizontal squash, default), 1 = horizontal axis */
    double axisspin_turns;    /* total rotations across the whole transition, default 6 */

    /* water ripple */
    double ripple_amp;      /* pixels, default 18 */
    double ripple_freq;     /* wave cycles per pixel-ish, default 0.15 */
    int    ripple_droplets; /* extra random droplets beyond the origin one, 0-4, default 0 */

    /* flickering light bulb */
    double flicker_min_brightness; /* floor, 0-1, default 0.12 */
    int    flicker_count;          /* number of flicker keyframes per half, default 8 */

    /* logo-sting -- non-owning pointer, loaded once per run by main.c
     * before the threaded render loop starts (never mutated by effects) */
    const buf_t *logo;
    double logo_static_frac;  /* fraction of total duration the logo holds still, default 0.15 */
    double logo_fadein_frac;  /* fraction spent fading/zooming the logo in, default 0.15 */
    double logo_spin_speed;   /* rotations during the zoom-out/spin phase, default 3.0 */
    double logo_zoom_speed;   /* easing exponent for the zoom-out phase, default 1.0 */
} tparams_t;

tparams_t tparams_defaults(void);

/* out must already be allocated at from->w x from->h (== to->w x to->h).
 * t is progress already passed through the configured easing curve, in [0,1]. */
typedef void (*transition_fn)(const buf_t *from, const buf_t *to, buf_t *out,
                               double t, const tparams_t *p);

/* Render rows [row0,row1) only -- lets the caller split work across threads. */
typedef void (*transition_fn_rows)(const buf_t *from, const buf_t *to, buf_t *out,
                                    double t, const tparams_t *p, int row0, int row1);

typedef struct {
    const char *name;
    transition_fn_rows fn;
    const char *description;
} transition_entry_t;

/* Returns NULL-terminated-by-count array; count via transitions_count(). */
const transition_entry_t *transitions_table(int *count);

/* Look up by name (case-insensitive). Returns NULL if not found. */
const transition_entry_t *transition_find(const char *name);

/* Pick a random transition from a comma-separated list of names
 * (e.g. "wave,pixelate,fade,circle-out"). Falls back to a uniformly
 * random pick over the whole table if list is NULL/empty. */
const transition_entry_t *transition_pick_random(const char *csv_list);

#endif
