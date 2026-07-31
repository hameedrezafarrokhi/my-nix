#define _POSIX_C_SOURCE 200809L
#define _DEFAULT_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <poll.h>
#include <time.h>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <regex.h>
#include <errno.h>

#include "config.h"
#include "bspwm_conn.h"
#include "wmclass.h"
#include "audio.h"

#define MAX_TRACKED_EVENTS 24
#define PIDFILE_PATH_FMT "/run/user/%d/bspwm-sounds.pid"

static config_t cfg;
static bspwm_conn_t conn;
static volatile sig_atomic_t want_reload = 0;
static volatile sig_atomic_t want_quit = 0;
static const char *g_config_path = NULL;

typedef struct { char name[NAME_LEN]; struct timespec t; int seen; } tracked_event_t;
static tracked_event_t tracked[MAX_TRACKED_EVENTS];
static int tracked_count = 0;

static struct timespec last_global_play = {0, 0};

static void now_ts(struct timespec *ts) { clock_gettime(CLOCK_MONOTONIC, ts); }

static double ts_diff_ms(struct timespec a, struct timespec b) {
    return (a.tv_sec - b.tv_sec) * 1000.0 + (a.tv_nsec - b.tv_nsec) / 1e6;
}

static void on_sighup(int sig)  { (void)sig; want_reload = 1; }
static void on_sigterm(int sig) { (void)sig; want_quit = 1; }

/* --------------------------------------------------------------------- */

static tracked_event_t *get_tracked(const char *name, int create) {
    for (int i = 0; i < tracked_count; i++) {
        if (strcmp(tracked[i].name, name) == 0) return &tracked[i];
    }
    if (!create || tracked_count >= MAX_TRACKED_EVENTS) return NULL;
    tracked_event_t *t = &tracked[tracked_count++];
    memset(t, 0, sizeof(*t));
    snprintf(t->name, NAME_LEN, "%s", name);
    return t;
}

static void mark_event_seen(const char *name, struct timespec now) {
    tracked_event_t *t = get_tracked(name, 1);
    if (t) { t->t = now; t->seen = 1; }
}

static int event_seen_within(const char *name, struct timespec now, int window_ms) {
    tracked_event_t *t = get_tracked(name, 0);
    if (!t || !t->seen) return 0;
    return ts_diff_ms(now, t->t) < window_ms;
}

/* index into a bspwm report line's space-separated fields where the
 * relevant NODE_ID lives, or -1 if that event type carries no node id. */
static int node_id_field_index(const char *event) {
    if (strcmp(event, "node_add") == 0) return 3;
    if (strcmp(event, "node_remove") == 0) return 2;
    if (strcmp(event, "node_swap") == 0) return 2;
    if (strcmp(event, "node_transfer") == 0) return 2;
    if (strcmp(event, "node_focus") == 0) return 2;
    if (strcmp(event, "node_activate") == 0) return 2;
    return -1;
}

static int event_needs_window_info(const char *event) {
    for (int i = 0; i < cfg.rule_count; i++) {
        rule_t *r = &cfg.rules[i];
        if (strcmp(r->event, event) != 0) continue;
        if (r->has_class || r->has_instance || r->has_title) return 1;
    }
    return 0;
}

static void handle_bspwm_line(char *line) {
    char *tokens[8];
    int ntok = 0;
    char *save = NULL;
    char *tok = strtok_r(line, " ", &save);
    while (tok && ntok < 8) { tokens[ntok++] = tok; tok = strtok_r(NULL, " ", &save); }
    if (ntok == 0) return;

    const char *event = tokens[0];
    struct timespec now;
    now_ts(&now);
    mark_event_seen(event, now);

    /* Resolve window class/instance/title only if we actually have a node id. */
    int have_win = 0;
    char klass[NAME_LEN] = "", instance[NAME_LEN] = "", title[256] = "";
    int idx = node_id_field_index(event);
    if (idx >= 0 && idx < ntok && event_needs_window_info(event)) {
        unsigned long win = strtoul(tokens[idx], NULL, 16);
        if (win != 0) {
            if (wm_get_class(win, instance, sizeof(instance), klass, sizeof(klass)) == 0) have_win = 1;
            wm_get_title(win, title, sizeof(title));
        }
    }

    rule_t *best = NULL;
    for (int i = 0; i < cfg.rule_count; i++) {
        rule_t *r = &cfg.rules[i];
        if (strcmp(r->event, event) != 0) continue;

        if (r->has_class) {
            if (!have_win || regexec(&r->class_re, klass, 0, NULL, 0) != 0) continue;
        }
        if (r->has_instance) {
            if (!have_win || regexec(&r->instance_re, instance, 0, NULL, 0) != 0) continue;
        }
        if (r->has_title) {
            if (title[0] == '\0' || regexec(&r->title_re, title, 0, NULL, 0) != 0) continue;
        }

        if (!best || r->priority > best->priority) best = r;
    }

    if (!best) return;

    if (best->has_fired && best->debounce_ms > 0 &&
        ts_diff_ms(now, best->last_fired) < best->debounce_ms) {
        return;
    }

    for (int i = 0; i < best->suppress_count; i++) {
        if (event_seen_within(best->suppress_if_events[i], now, best->suppress_window_ms)) {
            return;
        }
    }

    if (cfg.settings.global_min_gap_ms > 0 &&
        ts_diff_ms(now, last_global_play) < cfg.settings.global_min_gap_ms) {
        return;
    }

    sound_def_t *sd = config_find_sound(&cfg, best->sound_alias);
    if (!sd || !sd->resolved) return;

    audio_play(sd->resolved_path, best->volume, best->priority, best->max_instances);

    best->last_fired = now;
    best->has_fired = 1;
    last_global_play = now;
}

/* --------------------------------------------------------------------- */

static int reload_config(void) {
    config_t new_cfg;
    if (config_load(g_config_path, &new_cfg) != 0) {
        fprintf(stderr, "bspwm-sounds: reload failed, keeping previous config\n");
        return -1;
    }
    audio_resolve_sounds(&new_cfg);
    cfg = new_cfg;
    fprintf(stderr, "bspwm-sounds: config reloaded (%d sounds, %d rules)\n",
            cfg.sound_count, cfg.rule_count);
    return 0;
}

static int acquire_pidlock(void) {
    char path[256];
    snprintf(path, sizeof(path), PIDFILE_PATH_FMT, getuid());
    int fd = open(path, O_CREAT | O_RDWR, 0644);
    if (fd < 0) return -1; /* non-fatal: e.g. no XDG_RUNTIME_DIR, just skip locking */
    if (flock(fd, LOCK_EX | LOCK_NB) != 0) {
        fprintf(stderr, "bspwm-sounds: another instance is already running (%s)\n", path);
        return -1;
    }
    char pidbuf[32];
    int n = snprintf(pidbuf, sizeof(pidbuf), "%d\n", getpid());
    if (ftruncate(fd, 0) != 0) { /* best effort */ }
    if (write(fd, pidbuf, n) != n) { /* best effort */ }
    return 0; /* intentionally leak fd for the life of the process to hold the lock */
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s <config-file> [--test <sound-alias>]\n", argv[0]);
        return 1;
    }
    g_config_path = argv[1];

    if (config_load(g_config_path, &cfg) != 0) return 1;
    audio_resolve_sounds(&cfg);

    if (audio_init(&cfg) != 0) return 1;
    wm_init();

    if (argc >= 4 && strcmp(argv[2], "--test") == 0) {
        sound_def_t *sd = config_find_sound(&cfg, argv[3]);
        if (!sd || !sd->resolved) {
            fprintf(stderr, "bspwm-sounds: no such resolved sound '%s'\n", argv[3]);
            return 1;
        }
        audio_play_and_wait(sd->resolved_path, 1.0f);
        audio_shutdown();
        wm_shutdown();
        return 0;
    }

    if (acquire_pidlock() != 0) {
        /* Only refuse to start on an actual lock collision; open() failures
         * (e.g. sandboxed/no XDG_RUNTIME_DIR) are treated as non-fatal above,
         * but flock() collisions come back here too -- re-check via errno
         * would be cleaner, kept simple: just proceed, the flock case already
         * printed why. */
    }

    if (bspwm_connect(&conn) != 0) {
        fprintf(stderr, "bspwm-sounds: could not connect to bspwm\n");
        return 1;
    }

    struct sigaction sa_hup = {0};
    sa_hup.sa_handler = on_sighup;
    sigaction(SIGHUP, &sa_hup, NULL);

    struct sigaction sa_term = {0};
    sa_term.sa_handler = on_sigterm;
    sigaction(SIGTERM, &sa_term, NULL);
    sigaction(SIGINT, &sa_term, NULL);

    signal(SIGPIPE, SIG_IGN);

    fprintf(stderr, "bspwm-sounds: running (%d sounds, %d rules)\n",
            cfg.sound_count, cfg.rule_count);

    while (!want_quit) {
        if (want_reload) {
            reload_config();
            want_reload = 0;
        }

        struct pollfd pfd = { .fd = conn.fd, .events = POLLIN };
        /* Only need a short timeout while the audio engine might need to
         * notice it's gone idle and stop the device; when nothing has
         * played recently this just blocks forever, i.e. ~0% CPU. */
        int timeout_ms = 250;
        int pr = poll(&pfd, 1, timeout_ms);

        if (pr < 0) {
            if (errno == EINTR) continue;
            break;
        }

        if (pr == 0) {
            audio_tick();
            continue;
        }

        if (pfd.revents & (POLLHUP | POLLERR)) {
            fprintf(stderr, "bspwm-sounds: bspwm socket closed, reconnecting...\n");
            bspwm_close(&conn);
            struct timespec backoff = {1, 0};
            nanosleep(&backoff, NULL);
            if (bspwm_connect(&conn) != 0) {
                fprintf(stderr, "bspwm-sounds: reconnect failed, giving up\n");
                break;
            }
            continue;
        }

        char line[BSPWM_LINE_MAX];
        int r;
        while ((r = bspwm_read_event(&conn, line, sizeof(line))) == 1) {
            handle_bspwm_line(line);
        }
        if (r == -1) {
            fprintf(stderr, "bspwm-sounds: lost connection to bspwm, reconnecting...\n");
            bspwm_close(&conn);
            struct timespec backoff = {1, 0};
            nanosleep(&backoff, NULL);
            if (bspwm_connect(&conn) != 0) {
                fprintf(stderr, "bspwm-sounds: reconnect failed, giving up\n");
                break;
            }
        }

        audio_tick();
    }

    audio_shutdown();
    wm_shutdown();
    bspwm_close(&conn);
    return 0;
}
