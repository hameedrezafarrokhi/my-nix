#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <time.h>
#include <math.h>
#include <unistd.h>
#include <strings.h>

#include "config.h"
#include "image.h"
#include "transitions.h"
#include "xroot.h"
#include "lastrun.h"
#include "util.h"

#define XWWW_VERSION "1.0.0"

typedef struct {
    const transition_entry_t *entry;
    const buf_t *from, *to;
    buf_t *out;
    double t;
    const tparams_t *tp;
    int row0, row1;
} thread_job_t;

static void *thread_main(void *arg) {
    thread_job_t *j = (thread_job_t *)arg;
    j->entry->fn(j->from, j->to, j->out, j->t, j->tp, j->row0, j->row1);
    return NULL;
}

static void render_frame_threaded(const transition_entry_t *entry, const buf_t *from,
                                   const buf_t *to, buf_t *out, double t,
                                   const tparams_t *tp, int nthreads) {
    if (nthreads <= 1) {
        entry->fn(from, to, out, t, tp, 0, out->h);
        return;
    }
    pthread_t threads[64];
    thread_job_t jobs[64];
    if (nthreads > 64) nthreads = 64;
    int rows_per = (out->h + nthreads - 1) / nthreads;
    int n = 0;
    for (int i = 0; i < nthreads; i++) {
        int r0 = i * rows_per, r1 = r0 + rows_per;
        if (r0 >= out->h) break;
        if (r1 > out->h) r1 = out->h;
        jobs[n] = (thread_job_t){ entry, from, to, out, t, tp, r0, r1 };
        pthread_create(&threads[n], NULL, thread_main, &jobs[n]);
        n++;
    }
    for (int i = 0; i < n; i++) pthread_join(threads[i], NULL);
}

static int detect_ncpus(void) {
    long n = sysconf(_SC_NPROCESSORS_ONLN);
    return n > 0 ? (int)n : 2;
}

static int is_directory(const char *path) {
    struct stat st;
    if (stat(path, &st) != 0) return 0;
    return S_ISDIR(st.st_mode);
}

static const char *scale_mode_name(scale_mode_t m) {
    switch (m) {
        case SCALE_FIT: return "fit";
        case SCALE_STRETCH: return "stretch";
        case SCALE_CENTER: return "center";
        case SCALE_TILE: return "tile";
        default: return "fill";
    }
}

static void print_list(void) {
    int n;
    const transition_entry_t *tbl = transitions_table(&n);
    printf("%-14s %s\n", "NAME", "DESCRIPTION");
    for (int i = 0; i < n; i++)
        printf("%-14s %s\n", tbl[i].name, tbl[i].description);
}

/* Push `mon_frame` (monitor-sized, native mw x mh) as the current root
 * background. If the target monitor is the whole virtual screen,
 * mon_frame already *is* the full canvas, so it's pushed as-is. Otherwise
 * it's composited into `full` (the rest of the desktop, captured once at
 * startup) at (mx,my) first, so other monitors are left untouched. This
 * is called once per animation frame (not just the final one) -- see
 * xroot.h's xroot_push_frame() for why that's required for correctness. */
static void push(buf_t *full, int whole_root, int mx, int my, const buf_t *mon_frame) {
    if (whole_root) {
        xroot_push_frame(mon_frame);
    } else {
        buf_paste(full, mon_frame, mx, my);
        xroot_push_frame(full);
    }
}

int main(int argc, char **argv) {
    xwww_opts_t opts = opts_defaults();

    /* config file first (so CLI flags can override it), but we need to
     * know if -c/--config was given, so do a light pre-scan for it. */
    for (int i = 1; i < argc - 1; i++)
        if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--config") == 0)
            strncpy(opts.config_path, argv[i + 1], sizeof(opts.config_path) - 1);
    config_load(&opts, opts.config_path[0] ? opts.config_path : NULL);

    if (config_parse_args(&opts, argc, argv) != 0) return 2;
    if (opts.show_help) return 0;
    if (opts.show_version) { printf("xwww %s\n", XWWW_VERSION); return 0; }
    if (opts.list_only) { print_list(); return 0; }

    xrng_seed((uint64_t)time(NULL) ^ (uint64_t)getpid());
    opts.tp.seed = xrng_double();

    /* ---- resolve the image path ---- */
    char *resolved_path = NULL;
    int resolved_needs_free = 0;

    if (opts.restore_mode || opts.target[0] == 0) {
        resolved_path = lastrun_get_image();
        if (!resolved_path) {
            fprintf(stderr, "xwww: no image given and no $HOME/.xwww-bg to restore from\n");
            fprintf(stderr, "      usage: xwww <image-or-directory> [options]  (see --help)\n");
            return 1;
        }
        resolved_needs_free = 1;
        if (opts.restore_mode) { strcpy(opts.animation, "none"); opts.use_random = 0; }
    } else if (is_directory(opts.target)) {
        resolved_path = image_pick_random(opts.target);
        if (!resolved_path) {
            fprintf(stderr, "xwww: no images found in directory '%s'\n", opts.target);
            return 1;
        }
        resolved_needs_free = 1;
    } else {
        resolved_path = opts.target;
    }

    /* ---- pick the transition ---- */
    const transition_entry_t *entry;
    if (opts.use_random) {
        entry = transition_pick_random(opts.random_list[0] ? opts.random_list : NULL);
    } else {
        entry = transition_find(opts.animation);
        if (!entry) {
            fprintf(stderr, "xwww: unknown animation '%s', falling back to 'fade' "
                             "(see --list)\n", opts.animation);
            entry = transition_find("fade");
        }
    }
    int instant = (strcmp(entry->name, "none") == 0);

    /* ---- X11 setup ---- */
    if (xroot_init() != 0) { if (resolved_needs_free) free(resolved_path); return 1; }
    xroot_reclaim_previous();

    int root_w, root_h;
    xroot_get_size(&root_w, &root_h);

    monitor_t mons[16];
    int nmon = xroot_get_monitors(mons, 16);
    int mx = 0, my = 0, mw = root_w, mh = root_h;
    int whole_root = 1;
    if (strcasecmp(opts.output, "all") != 0 && strcasecmp(opts.output, "span") != 0) {
        int found = 0;
        for (int i = 0; i < nmon; i++) {
            if (strcasecmp(mons[i].name, opts.output) == 0) {
                mx = mons[i].x; my = mons[i].y; mw = mons[i].w; mh = mons[i].h;
                whole_root = (mw == root_w && mh == root_h && mx == 0 && my == 0);
                found = 1;
                break;
            }
        }
        if (!found)
            fprintf(stderr, "xwww: warning: output '%s' not found, using whole screen "
                             "(monitor names are monitor-0, monitor-1, ...)\n", opts.output);
    }

    /* ---- load + compose the new wallpaper ---- */
    buf_t src_img;
    if (image_load(resolved_path, &src_img) != 0) {
        xroot_shutdown();
        if (resolved_needs_free) free(resolved_path);
        return 1;
    }
    buf_t to_mon = image_compose_to_canvas(&src_img, mw, mh, opts.scale_mode, opts.bg_color);
    buf_free(&src_img);

    /* ---- capture whatever's already on screen, if we need it: either
     * as the transition's "from" frame, or as the rest of the desktop
     * that a single-monitor push has to preserve. ---- */
    int need_capture = !instant || !whole_root;
    buf_t full = { 0, 0, NULL };
    buf_t from_mon = { 0, 0, NULL };
    int from_is_full = 0;
    if (need_capture) {
        xroot_capture(&full, 0, 0, root_w, root_h);
        if (whole_root) { from_mon = full; from_is_full = 1; }
        else from_mon = buf_crop(&full, mx, my, mw, mh);
    }

    int nthreads = opts.threads > 0 ? opts.threads : detect_ncpus();

    if (!instant) {
        /* animation canvas, possibly downscaled for perf */
        int aw = mw, ah = mh;
        buf_t from_anim = from_mon, to_anim = to_mon;
        int allocated_anim = 0;
        if (opts.render_scale < 0.999) {
            aw = (int)(mw * opts.render_scale); if (aw < 8) aw = 8;
            ah = (int)(mh * opts.render_scale); if (ah < 8) ah = 8;
            from_anim = buf_resize(&from_mon, aw, ah);
            to_anim = buf_resize(&to_mon, aw, ah);
            allocated_anim = 1;
        }
        buf_t out_anim = buf_alloc(aw, ah);
        int need_upscale = (aw != mw || ah != mh);

        int frames;
        double frame_interval = 0; /* seconds, 0 = no explicit pacing */
        if (opts.duration_ms > 0) {
            double fps_target = opts.fps_cap > 0 ? opts.fps_cap : 60.0;
            frames = (int)lround(opts.duration_ms / 1000.0 * fps_target);
            if (frames < 2) frames = 2;
            frame_interval = (opts.duration_ms / 1000.0) / frames;
        } else {
            frames = opts.frames > 1 ? opts.frames : 2;
            if (opts.fps_cap > 0) frame_interval = 1.0 / opts.fps_cap;
        }

        for (int i = 0; i < frames; i++) {
            double t0 = now_seconds();
            double raw_t = (double)i / (frames - 1);
            double t = easing_apply(opts.easing, raw_t);

            render_frame_threaded(entry, &from_anim, &to_anim, &out_anim, t, &opts.tp, nthreads);

            if (need_upscale) {
                buf_t upscaled = buf_resize(&out_anim, mw, mh);
                push(&full, whole_root, mx, my, &upscaled);
                buf_free(&upscaled);
            } else {
                push(&full, whole_root, mx, my, &out_anim);
            }

            if (frame_interval > 0) {
                double elapsed = now_seconds() - t0;
                if (elapsed < frame_interval) sleep_seconds(frame_interval - elapsed);
            }
        }

        buf_free(&out_anim);
        if (allocated_anim) { buf_free(&from_anim); buf_free(&to_anim); }
    }

    /* ---- final frame, always full quality regardless of RENDER_SCALE ---- */
    push(&full, whole_root, mx, my, &to_mon);

    if (!opts.no_save)
        lastrun_save(resolved_path, scale_mode_name(opts.scale_mode), "#000000");

    if (need_capture) {
        if (!from_is_full) buf_free(&from_mon);
        buf_free(&full);
    }
    buf_free(&to_mon);
    xroot_shutdown();
    if (resolved_needs_free) free(resolved_path);
    return 0;
}
