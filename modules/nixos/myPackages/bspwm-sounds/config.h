#ifndef CONFIG_H
#define CONFIG_H

#include <regex.h>
#include <time.h>

#define MAX_SOUNDS   64
#define MAX_RULES    128
#define MAX_SUPPRESS 8
#define NAME_LEN     64
#define PATH_LEN     512
#define PAT_LEN      160

typedef struct {
    char alias[NAME_LEN];
    char src_path[PATH_LEN];      /* as given in config, ~ expanded      */
    char resolved_path[PATH_LEN]; /* native (wav/mp3) path actually used */
    int  resolved;                /* resolved_path is valid              */
} sound_def_t;

typedef struct {
    char name[NAME_LEN];
    char event[NAME_LEN];        /* e.g. node_add, node_focus, desktop_focus */

    int  has_class;    regex_t class_re;    char class_pat[PAT_LEN];
    int  has_instance; regex_t instance_re; char instance_pat[PAT_LEN];
    int  has_title;    regex_t title_re;    char title_pat[PAT_LEN];

    char sound_alias[NAME_LEN];
    float volume;         /* 0.0 - ~2.0 */
    int   priority;       /* higher wins voice contention              */
    int   debounce_ms;    /* min gap between firings of this rule      */
    int   max_instances;  /* cap on simultaneous copies of this rule's sound (0 = use global max_voices) */

    char  suppress_if_events[MAX_SUPPRESS][NAME_LEN];
    int   suppress_count;
    int   suppress_window_ms;

    /* runtime state, not parsed from file */
    struct timespec last_fired;
    int   has_fired;
} rule_t;

typedef struct {
    int   sample_rate;
    int   channels;
    int   max_voices;
    char  cache_dir[PATH_LEN];
    int   idle_shutdown_ms;
    float master_volume;
    char  ffmpeg_path[PATH_LEN];
    int   global_min_gap_ms; /* absolute floor between ANY two sounds starting, extra safety valve */
} settings_t;

typedef struct {
    settings_t   settings;
    sound_def_t  sounds[MAX_SOUNDS];
    int          sound_count;
    rule_t       rules[MAX_RULES];
    int          rule_count;
} config_t;

/* Loads (or reloads) a config file into cfg. Returns 0 on success. */
int config_load(const char *path, config_t *cfg);

/* Looks up a sound definition by alias. Returns NULL if not found. */
sound_def_t *config_find_sound(config_t *cfg, const char *alias);

#endif
