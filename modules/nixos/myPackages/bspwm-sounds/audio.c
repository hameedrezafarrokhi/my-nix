#define _POSIX_C_SOURCE 200809L
#define _DEFAULT_SOURCE
#include "audio.h"

#define MA_NO_ENCODING
#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <libgen.h>

#define MAX_VOICES_HARD 64

typedef struct {
    ma_sound sound;
    int   active;      /* sound object is initialized and possibly playing */
    int   priority;
    char  path[PATH_LEN];
    struct timespec started;
} voice_t;

static ma_engine engine;
static int engine_alive = 0;         /* fully init()'d and connected right now  */
static settings_t saved_settings;    /* kept so we can cold re-init on demand   */
static voice_t voices[MAX_VOICES_HARD];
static int voice_count = 8;
static int idle_shutdown_ms = 200;
static struct timespec last_activity;
static int have_activity = 0;

static double ts_diff_ms(struct timespec a, struct timespec b) {
    return (a.tv_sec - b.tv_sec) * 1000.0 + (a.tv_nsec - b.tv_nsec) / 1e6;
}

static void now_ts(struct timespec *ts) {
    clock_gettime(CLOCK_MONOTONIC, ts);
}

int audio_init(config_t *cfg) {
    saved_settings = cfg->settings;

    voice_count = cfg->settings.max_voices;
    if (voice_count <= 0) voice_count = 1;
    if (voice_count > MAX_VOICES_HARD) voice_count = MAX_VOICES_HARD;
    memset(voices, 0, sizeof(voices));

    idle_shutdown_ms = cfg->settings.idle_shutdown_ms;
    if (idle_shutdown_ms <= 0) idle_shutdown_ms = 1;

    /* Deliberately do NOT open the audio device here. The engine is
     * initialized lazily on first audio_play() and fully uninitialized
     * again by audio_tick() after idle_shutdown_ms of silence -- see the
     * comment on ensure_engine_alive()/teardown_engine() below for why
     * this is init/uninit and not just start/stop. */
    engine_alive = 0;
    have_activity = 0;
    return 0;
}

/* ---- ogg/opus/etc -> cached wav transcoding -------------------------- */

static unsigned long simple_hash(const char *s) {
    unsigned long h = 5381;
    int c;
    while ((c = (unsigned char)*s++)) h = ((h << 5) + h) + (unsigned long)c;
    return h;
}

static int is_natively_decodable(const char *path) {
    const char *dot = strrchr(path, '.');
    if (!dot) return 0;
    return (strcasecmp(dot, ".wav") == 0 ||
            strcasecmp(dot, ".mp3") == 0 ||
            strcasecmp(dot, ".flac") == 0);
}

static int ensure_dir(const char *dir) {
    struct stat st;
    if (stat(dir, &st) == 0) return S_ISDIR(st.st_mode) ? 0 : -1;

    char tmp[PATH_LEN];
    snprintf(tmp, sizeof(tmp), "%s", dir);
    size_t len = strlen(tmp);
    if (len > 0 && tmp[len - 1] == '/') tmp[len - 1] = '\0';

    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            if (stat(tmp, &st) != 0) {
                if (mkdir(tmp, 0755) != 0 && errno != EEXIST) return -1;
            }
            *p = '/';
        }
    }
    if (stat(tmp, &st) != 0) {
        if (mkdir(tmp, 0755) != 0 && errno != EEXIST) return -1;
    }
    return 0;
}

static int transcode_to_wav(const char *ffmpeg_path, const char *src, const char *dst,
                             int sample_rate, int channels) {
    pid_t pid = fork();
    if (pid < 0) {
        fprintf(stderr, "bspwm-sounds: fork() failed for ffmpeg: %m\n");
        return -1;
    }
    if (pid == 0) {
        char rate_buf[32], ch_buf[32];
        snprintf(rate_buf, sizeof(rate_buf), "%d", sample_rate);
        snprintf(ch_buf, sizeof(ch_buf), "%d", channels);
        int devnull = open("/dev/null", O_WRONLY);
        if (devnull >= 0) {
            dup2(devnull, STDOUT_FILENO);
            dup2(devnull, STDERR_FILENO);
        }
        execlp(ffmpeg_path, ffmpeg_path,
               "-y", "-loglevel", "error",
               "-i", src,
               "-ar", rate_buf, "-ac", ch_buf,
               dst, (char *)NULL);
        _exit(127);
    }
    int status = 0;
    if (waitpid(pid, &status, 0) < 0) return -1;
    return (WIFEXITED(status) && WEXITSTATUS(status) == 0) ? 0 : -1;
}

void audio_resolve_sounds(config_t *cfg) {
    ensure_dir(cfg->settings.cache_dir);

    for (int i = 0; i < cfg->sound_count; i++) {
        sound_def_t *sd = &cfg->sounds[i];
        sd->resolved = 0;

        struct stat st;
        if (stat(sd->src_path, &st) != 0) {
            fprintf(stderr, "bspwm-sounds: sound '%s': cannot stat '%s': %m\n",
                    sd->alias, sd->src_path);
            continue;
        }

        if (is_natively_decodable(sd->src_path)) {
            snprintf(sd->resolved_path, PATH_LEN, "%s", sd->src_path);
            sd->resolved = 1;
            continue;
        }

        /* Needs transcoding. Cache key covers path + mtime + size so an
         * edited source file is automatically re-transcoded. */
        char key[PATH_LEN + 64];
        snprintf(key, sizeof(key), "%s|%ld|%ld", sd->src_path,
                 (long)st.st_mtime, (long)st.st_size);
        unsigned long h = simple_hash(key);

        char base_copy[PATH_LEN];
        snprintf(base_copy, sizeof(base_copy), "%s", sd->src_path);
        char *base = basename(base_copy);

        char cache_path[PATH_LEN];
        snprintf(cache_path, PATH_LEN, "%s/%s-%08lx.wav", cfg->settings.cache_dir, base, h);

        if (stat(cache_path, &st) != 0) {
            fprintf(stderr, "bspwm-sounds: transcoding '%s' -> cache (one-time)...\n", sd->src_path);
            if (transcode_to_wav(cfg->settings.ffmpeg_path, sd->src_path, cache_path,
                                  cfg->settings.sample_rate, cfg->settings.channels) != 0) {
                fprintf(stderr, "bspwm-sounds: sound '%s': ffmpeg transcode failed "
                                "(is ffmpeg installed and on PATH?)\n", sd->alias);
                continue;
            }
        }

        snprintf(sd->resolved_path, PATH_LEN, "%s", cache_path);
        sd->resolved = 1;
    }
}

/* ---- playback / voice pool -------------------------------------------- */

/* Fully connects to the audio backend (opens the PipeWire/Pulse/ALSA
 * stream) if it isn't already. This is the expensive-ish operation
 * (typically single-digit-to-tens of milliseconds), done lazily on the
 * first sound of a burst rather than at startup. */
static int ensure_engine_alive(void) {
    if (engine_alive) return 0;

    ma_engine_config econf = ma_engine_config_init();
    econf.channels = (ma_uint32)saved_settings.channels;
    econf.sampleRate = (ma_uint32)saved_settings.sample_rate;

    if (ma_engine_init(&econf, &engine) != MA_SUCCESS) {
        fprintf(stderr, "bspwm-sounds: failed to initialize audio engine\n");
        return -1;
    }
    ma_engine_set_volume(&engine, saved_settings.master_volume);
    engine_alive = 1;
    return 0;
}

/* Fully disconnects from the audio backend. This is the important part:
 * ma_engine_stop()/ma_device_stop() merely pauses (Pulse: "corks") the
 * stream -- the client stays attached to PipeWire's graph and can still
 * get woken up periodically by its scheduling/housekeeping even while
 * producing nothing. Only a full ma_engine_uninit() actually drops the
 * client connection, which is what gets CPU usage to genuine zero between
 * bursts of sounds instead of "very low, but not zero, forever." */
static void teardown_engine(void) {
    if (!engine_alive) return;
    for (int i = 0; i < voice_count; i++) {
        if (voices[i].active) {
            ma_sound_uninit(&voices[i].sound);
            voices[i].active = 0;
        }
    }
    ma_engine_uninit(&engine);
    engine_alive = 0;
}

static int voice_is_free(voice_t *v) {
    if (!v->active) return 1;
    return !ma_sound_is_playing(&v->sound);
}

static void voice_release(voice_t *v) {
    if (v->active) {
        ma_sound_uninit(&v->sound);
        v->active = 0;
    }
}

static int count_active_for_path(const char *path) {
    int n = 0;
    for (int i = 0; i < voice_count; i++) {
        if (voices[i].active && ma_sound_is_playing(&voices[i].sound) &&
            strcmp(voices[i].path, path) == 0) {
            n++;
        }
    }
    return n;
}

void audio_play(const char *path, float volume, int priority, int max_instances) {
    if (!path || !*path) return;

    if (max_instances > 0 && count_active_for_path(path) >= max_instances) {
        return; /* per-sound cap reached; drop rather than queue */
    }

    if (ensure_engine_alive() != 0) return;

    /* Find a free slot first. */
    voice_t *slot = NULL;
    for (int i = 0; i < voice_count; i++) {
        if (voice_is_free(&voices[i])) { slot = &voices[i]; break; }
    }

    /* No free slot: evict the lowest-priority currently-playing voice if
     * the new sound outranks it. Otherwise drop the new sound. */
    if (!slot) {
        int min_idx = -1;
        int min_priority = 0;
        for (int i = 0; i < voice_count; i++) {
            if (!voices[i].active) continue;
            if (min_idx == -1 || voices[i].priority < min_priority) {
                min_idx = i;
                min_priority = voices[i].priority;
            }
        }
        if (min_idx != -1 && priority > min_priority) {
            slot = &voices[min_idx];
        } else {
            return; /* everything currently playing outranks this; drop it */
        }
    }

    voice_release(slot);

    if (ma_sound_init_from_file(&engine, path, MA_SOUND_FLAG_DECODE, NULL, NULL, &slot->sound) != MA_SUCCESS) {
        fprintf(stderr, "bspwm-sounds: failed to load sound '%s'\n", path);
        return;
    }

    ma_sound_set_volume(&slot->sound, volume);
    ma_sound_start(&slot->sound);

    slot->active = 1;
    slot->priority = priority;
    snprintf(slot->path, PATH_LEN, "%s", path);
    now_ts(&slot->started);
    now_ts(&last_activity);
    have_activity = 1;
}

void audio_play_and_wait(const char *path, float volume) {
    if (ensure_engine_alive() != 0) return;

    ma_sound s;
    if (ma_sound_init_from_file(&engine, path, MA_SOUND_FLAG_DECODE, NULL, NULL, &s) != MA_SUCCESS) {
        fprintf(stderr, "bspwm-sounds: failed to load sound '%s'\n", path);
        return;
    }
    ma_sound_set_volume(&s, volume);
    ma_sound_start(&s);
    while (ma_sound_is_playing(&s)) {
        struct timespec req = {0, 20 * 1000 * 1000};
        nanosleep(&req, NULL);
    }
    ma_sound_uninit(&s);
}

void audio_tick(void) {
    if (!engine_alive) return; /* nothing connected, nothing to do -- true idle */

    int any_playing = 0;
    for (int i = 0; i < voice_count; i++) {
        if (!voices[i].active) continue;
        if (ma_sound_is_playing(&voices[i].sound)) {
            any_playing = 1;
        } else {
            voice_release(&voices[i]); /* free finished voices promptly */
        }
    }

    if (any_playing) {
        now_ts(&last_activity);
        have_activity = 1;
        return;
    }

    struct timespec t; now_ts(&t);
    if (have_activity && ts_diff_ms(t, last_activity) >= idle_shutdown_ms) {
        teardown_engine();
        have_activity = 0;
    }
}

void audio_shutdown(void) {
    teardown_engine();
}
