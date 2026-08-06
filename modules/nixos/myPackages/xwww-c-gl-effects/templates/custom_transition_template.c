/* Template: adding your own transition effect to xwww.
 *
 * xwww does not (yet) load transitions as runtime plugins -- effects are
 * plain C functions compiled into the binary and registered in a table.
 * That keeps things simple, dependency-free, and exactly as fast as every
 * built-in effect. Adding one is a 3-step copy/paste job:
 *
 *   1. Copy the function below into src/transitions.c (anywhere above the
 *      `TABLE[]` array near the bottom of the file).
 *   2. Add a line for it to `TABLE[]`:
 *        { "my-effect", fx_my_effect, "one-line description" },
 *   3. `make` and run `xwww <image> --animation my-effect`.
 *
 * --- What you get ----------------------------------------------------
 *   from, to   : buf_t* -- the outgoing and incoming images, both already
 *                scaled/cropped/letterboxed to the exact output size per
 *                --scale-mode. Same w/h as `out`. Pixels are packed
 *                0xAARRGGBB (see buffer.h for px_a/px_r/px_g/px_b/px_pack
 *                and px_lerp for per-channel blending).
 *   out        : buf_t* -- write your result here. Already allocated.
 *   t          : double in [0,1] -- transition progress, AFTER easing has
 *                already been applied (t=0 is "from", t=1 is "to").
 *   p          : tparams_t* -- the shared per-effect tuning knobs
 *                (wave_amp, pixelate_size, blinds_count, checker_size,
 *                seed, ...) sourced from the config file / CLI flags.
 *   row0, row1 : the half-open row range [row0, row1) you must fill in.
 *                xwww calls your function once per worker thread with a
 *                different row range each time (or once with the full
 *                range [0, out->h) if running single-threaded) -- so:
 *
 *     ALWAYS loop `for (int y = row0; y < row1; y++)`, never `y = 0`.
 *     NEVER allocate/free memory, spawn threads, or use static/global
 *     mutable state inside the function -- it runs concurrently across
 *     rows on multiple threads.
 *     bilinear sampling (buf_sample_bilinear) and buf_get()/buf_set() are
 *     fine to use and already clamp out-of-range coordinates.
 *
 * The example below is a simple new effect: a wipe boundary shaped like a
 * V (two diagonal lines meeting at the bottom-center), included mainly to
 * show the shape of a real, working effect you can riff on.
 */

#include "transitions.h"
#include <math.h>

static void fx_my_effect(const buf_t *from, const buf_t *to, buf_t *out,
                          double t, const tparams_t *p, int row0, int row1) {
    (void)p; /* unused here -- use p->wave_amp etc. if your effect needs tuning */

    int w = from->w, h = from->h;
    double cx = w / 2.0;

    for (int y = row0; y < row1; y++) {
        /* distance from the V shape's apex (bottom-center), growing upward */
        double dist_from_apex = (h - y);
        for (int x = 0; x < w; x++) {
            double v_boundary = fabs(x - cx) + dist_from_apex * 0.5;
            int reveal = v_boundary < t * (w + h);

            size_t i = (size_t)y * w + x;
            out->pix[i] = reveal ? to->pix[i] : from->pix[i];
        }
    }
}

/* Then in src/transitions.c's TABLE[]:
 *   { "v-wipe", fx_my_effect, "V-shaped wipe from bottom-center" },
 */
