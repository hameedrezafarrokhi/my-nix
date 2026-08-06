#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <time.h>
#include <math.h>
#include <unistd.h>
#include <strings.h>
#include <signal.h>
#include <pwd.h>
#include <errno.h>
#include <fcntl.h>

#include "config.h"
#include "image.h"
#include "transitions.h"
#include "xroot.h"
#include "lastrun.h"
#include "util.h"
#include "gl_effects.h"

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
    printf("%-16s %s\n", "NAME", "DESCRIPTION");
    for (int i = 0; i < n; i++)
        printf("%-16s %s\n", tbl[i].name, tbl[i].description);
}

static double apply_easing(const xwww_opts_t *opts, double raw_t) {
    if (opts->easing == EASE_CUSTOM_BEZIER)
        return easing_bezier(opts->bezier[0], opts->bezier[1], opts->bezier[2], opts->bezier[3], raw_t);
    return easing_apply(opts->easing, raw_t);
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

/* Fire-and-forget playback for logo-sting's optional sound: tries a
 * chain of common players and doesn't wait for it. main() sets
 * SIGCHLD to SIG_IGN so the child is auto-reaped without a zombie. */
static void play_sound_async(const char *path) {
    pid_t pid = fork();
    if (pid < 0) return;
    if (pid == 0) {
        int devnull = open("/dev/null", O_RDWR);
        if (devnull >= 0) {
            dup2(devnull, STDIN_FILENO);
            dup2(devnull, STDOUT_FILENO);
            dup2(devnull, STDERR_FILENO);
        }
        execlp("paplay", "paplay", path, (char *)NULL);
        execlp("aplay", "aplay", "-q", path, (char *)NULL);
        execlp("ffplay", "ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", path, (char *)NULL);
        execlp("mpv", "mpv", "--no-video", "--really-quiet", path, (char *)NULL);
        _exit(127);
    }
}

/* Runs one full "set this wallpaper with a transition" cycle against an
 * already-initialized X11 connection. Used both by the normal one-shot
 * path and, repeatedly, by slideshow mode. Returns 0 on success. */
static int set_wallpaper(xwww_opts_t *opts, const char *resolved_path,
                          int root_w, int root_h, monitor_t *mons, int nmon) {
    const transition_entry_t *entry;
    if (opts->use_random) {
        entry = transition_pick_random(opts->random_list[0] ? opts->random_list : NULL);
    } else {
        entry = transition_find(opts->animation);
        if (!entry) {
            fprintf(stderr, "xwww: unknown animation '%s', falling back to 'fade' "
                             "(see --list)\n", opts->animation);
            entry = transition_find("fade");
        }
    }
    /* Per-effect config-file overrides (a "[effect-name]" section) are the
     * most specific scope, so they're applied last, after CLI flags. */
    config_apply_effect_section(opts, entry->name);

    int instant = (strcmp(entry->name, "none") == 0);

    /* logo-sting's asset: loaded once here (never inside the threaded
     * render loop -- see tparams_t's `logo` field), freed at the end. */
    buf_t logo_buf = { 0, 0, NULL };
    int logo_loaded = 0;
    if (strcmp(entry->name, "logo-sting") == 0 && opts->logo_path[0]) {
        char *logo_owned = NULL;
        const char *logo_resolved = opts->logo_path;
        if (is_directory(opts->logo_path)) {
            logo_owned = image_pick_random(opts->logo_path);
            if (logo_owned) logo_resolved = logo_owned;
        }
        if (image_load(logo_resolved, &logo_buf) == 0) {
            opts->tp.logo = &logo_buf;
            logo_loaded = 1;
        } else {
            fprintf(stderr, "xwww: warning: could not load logo image '%s', "
                             "logo-sting will just fade\n", logo_resolved);
        }
        if (logo_owned) free(logo_owned);
        if (opts->logo_sound[0]) play_sound_async(opts->logo_sound);
    }

    int mx = 0, my = 0, mw = root_w, mh = root_h;
    int whole_root = 1;
    if (strcasecmp(opts->output, "all") != 0 && strcasecmp(opts->output, "span") != 0) {
        int found = 0;
        for (int i = 0; i < nmon; i++) {
            if (strcasecmp(mons[i].name, opts->output) == 0) {
                mx = mons[i].x; my = mons[i].y; mw = mons[i].w; mh = mons[i].h;
                whole_root = (mw == root_w && mh == root_h && mx == 0 && my == 0);
                found = 1;
                break;
            }
        }
        if (!found)
            fprintf(stderr, "xwww: warning: output '%s' not found, using whole screen "
                             "(monitor names are monitor-0, monitor-1, ...)\n", opts->output);
    }

    buf_t src_img;
    if (image_load(resolved_path, &src_img) != 0) return -1;
    buf_t to_mon = image_compose_to_canvas(&src_img, mw, mh, opts->scale_mode, opts->bg_color);
    buf_free(&src_img);

    int need_capture = !instant || !whole_root;
    buf_t full = { 0, 0, NULL };
    buf_t from_mon = { 0, 0, NULL };
    int from_is_full = 0;
    if (need_capture) {
        xroot_capture(&full, 0, 0, root_w, root_h);
        if (whole_root) { from_mon = full; from_is_full = 1; }
        else from_mon = buf_crop(&full, mx, my, mw, mh);
    }

    int nthreads = opts->threads > 0 ? opts->threads : detect_ncpus();

    if (!instant) {
        int aw = mw, ah = mh;
        buf_t from_anim = from_mon, to_anim = to_mon;
        int allocated_anim = 0;
        if (opts->render_scale < 0.999) {
            aw = (int)(mw * opts->render_scale); if (aw < 8) aw = 8;
            ah = (int)(mh * opts->render_scale); if (ah < 8) ah = 8;
            from_anim = buf_resize(&from_mon, aw, ah);
            to_anim = buf_resize(&to_mon, aw, ah);
            allocated_anim = 1;
        }
        buf_t out_anim = buf_alloc(aw, ah);
        int need_upscale = (aw != mw || ah != mh);

        int frames;
        double frame_interval = 0;
        if (opts->duration_ms > 0) {
            double fps_target = opts->fps_cap > 0 ? opts->fps_cap : 60.0;
            frames = (int)lround(opts->duration_ms / 1000.0 * fps_target);
            if (frames < 2) frames = 2;
            frame_interval = (opts->duration_ms / 1000.0) / frames;
        } else {
            frames = opts->frames > 1 ? opts->frames : 2;
            if (opts->fps_cap > 0) frame_interval = 1.0 / opts->fps_cap;
        }

        int use_gl = gl_effect_exists(entry->name);
        for (int i = 0; i < frames; i++) {
            double t0 = now_seconds();
            double raw_t = (double)i / (frames - 1);
            double t = apply_easing(opts, raw_t);

            int gl_done = use_gl && (gl_render_effect(entry->name, &from_anim, &to_anim, &out_anim, t, &opts->tp) == 0);
            if (!gl_done)
                render_frame_threaded(entry, &from_anim, &to_anim, &out_anim, t, &opts->tp, nthreads);

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

    push(&full, whole_root, mx, my, &to_mon);

    if (!opts->no_save)
        lastrun_save(resolved_path, scale_mode_name(opts->scale_mode), "#000000");

    if (need_capture) {
        if (!from_is_full) buf_free(&from_mon);
        buf_free(&full);
    }
    buf_free(&to_mon);
    if (logo_loaded) { buf_free(&logo_buf); opts->tp.logo = NULL; }
    return 0;
}

/* ------------------------------------------------------------ slideshow */

static volatile sig_atomic_t g_stop_requested = 0;
static void on_stop_signal(int sig) { (void)sig; g_stop_requested = 1; }

static void sleep_interruptible(double seconds) {
    double remaining = seconds;
    while (remaining > 0 && !g_stop_requested) {
        double chunk = remaining > 1.0 ? 1.0 : remaining;
        sleep_seconds(chunk);
        remaining -= chunk;
    }
}

static void pidfile_path(char *out, size_t n) {
    const char *home = getenv("HOME");
    if (!home) { struct passwd *pw = getpwuid(getuid()); home = pw ? pw->pw_dir : "/tmp"; }
    snprintf(out, n, "%s/.xwww-slideshow.pid", home);
}

static int slideshow_stop_command(void) {
    char path[4200];
    pidfile_path(path, sizeof(path));
    FILE *f = fopen(path, "r");
    if (!f) { fprintf(stderr, "xwww: no slideshow pidfile at %s\n", path); return 1; }
    pid_t pid;
    int ok = (fscanf(f, "%d", &pid) == 1);
    fclose(f);
    if (!ok) { fprintf(stderr, "xwww: could not read pid from %s\n", path); return 1; }
    if (kill(pid, SIGTERM) != 0) {
        fprintf(stderr, "xwww: could not signal pid %d: %s\n", (int)pid, strerror(errno));
        remove(path);
        return 1;
    }
    remove(path);
    printf("xwww: stopped slideshow (pid %d)\n", (int)pid);
    return 0;
}

static void free_image_list(char **list, int n) {
    for (int i = 0; i < n; i++) free(list[i]);
    free(list);
}

static int slideshow_run(xwww_opts_t *opts) {
    if (!is_directory(opts->slideshow_dir)) {
        fprintf(stderr, "xwww: slideshow path '%s' is not a directory\n", opts->slideshow_dir);
        return 1;
    }

    if (opts->slideshow_daemonize) {
        pid_t pid = fork();
        if (pid < 0) { perror("xwww: fork"); return 1; }
        if (pid > 0) {
            char path[4200];
            pidfile_path(path, sizeof(path));
            FILE *f = fopen(path, "w");
            if (f) { fprintf(f, "%d\n", (int)pid); fclose(f); }
            printf("xwww: slideshow started in background, pid %d (stop with "
                   "`xwww --slideshow-stop`)\n", (int)pid);
            return 0;
        }
        setsid();
        freopen("/dev/null", "r", stdin);
        freopen("/dev/null", "w", stdout);
        freopen("/dev/null", "w", stderr);
    }

    signal(SIGTERM, on_stop_signal);
    signal(SIGINT, on_stop_signal);

    if (xroot_init() != 0) return 1;
    xroot_reclaim_previous();
    int root_w, root_h;
    xroot_get_size(&root_w, &root_h);
    monitor_t mons[16];
    int nmon = xroot_get_monitors(mons, 16);

    int seq_idx = 0;
    while (!g_stop_requested) {
        char **list;
        int n = image_list_sorted(opts->slideshow_dir, &list);
        if (n == 0) {
            sleep_interruptible(opts->slideshow_interval);
            continue;
        }

        int idx = opts->slideshow_shuffle ? xrng_int(0, n - 1) : (seq_idx++ % n);
        char path[4096];
        snprintf(path, sizeof(path), "%s/%s", opts->slideshow_dir, list[idx]);
        free_image_list(list, n);

        set_wallpaper(opts, path, root_w, root_h, mons, nmon);

        sleep_interruptible(opts->slideshow_interval);
    }

    xroot_shutdown();
    if (opts->slideshow_daemonize) {
        char path[4200];
        pidfile_path(path, sizeof(path));
        remove(path);
    }
    return 0;
}

/* ----------------------------------------------------------------- main */

int main(int argc, char **argv) {
    xwww_opts_t opts = opts_defaults();
    signal(SIGCHLD, SIG_IGN);

    for (int i = 1; i < argc - 1; i++)
        if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--config") == 0)
            strncpy(opts.config_path, argv[i + 1], sizeof(opts.config_path) - 1);
    config_load(&opts, opts.config_path[0] ? opts.config_path : NULL);

    if (config_parse_args(&opts, argc, argv) != 0) return 2;
    if (opts.show_help) return 0;
    if (opts.show_version) { printf("xwww %s\n", XWWW_VERSION); return 0; }
    if (opts.list_only) { print_list(); return 0; }
    if (opts.slideshow_stop) return slideshow_stop_command();

    xrng_seed((uint64_t)time(NULL) ^ (uint64_t)getpid());
    opts.tp.seed = xrng_double();

    if (opts.slideshow_dir[0]) return slideshow_run(&opts);

    /* ---- normal one-shot path ---- */
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

    if (xroot_init() != 0) { if (resolved_needs_free) free(resolved_path); return 1; }
    xroot_reclaim_previous();

    int root_w, root_h;
    xroot_get_size(&root_w, &root_h);
    monitor_t mons[16];
    int nmon = xroot_get_monitors(mons, 16);

    int rc = set_wallpaper(&opts, resolved_path, root_w, root_h, mons, nmon);

    xroot_shutdown();
    if (resolved_needs_free) free(resolved_path);
    return rc == 0 ? 0 : 1;
}
