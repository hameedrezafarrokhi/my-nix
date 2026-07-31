#ifndef XWWW_TRANSITIONS_H
#define XWWW_TRANSITIONS_H

#include "buffer.h"
#include "util.h"

typedef struct {
    double wave_amp;       /* pixels */
    double wave_length;    /* pixels */
    int    pixelate_size;  /* max block size, pixels */
    int    blinds_count;   /* number of stripes */
    int    checker_size;   /* pixels per checker cell */
    double seed;           /* per-run random seed in [0,1), for dissolve/checker ordering */
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
