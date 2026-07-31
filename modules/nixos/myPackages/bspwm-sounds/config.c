#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <wordexp.h>

static void trim(char *s) {
    char *start = s;
    while (isspace((unsigned char)*start)) start++;
    if (start != s) memmove(s, start, strlen(start) + 1);
    size_t n = strlen(s);
    while (n > 0 && isspace((unsigned char)s[n - 1])) s[--n] = '\0';
}

static void expand_path(const char *in, char *out, size_t out_sz) {
    wordexp_t we;
    if (wordexp(in, &we, 0) == 0 && we.we_wordc > 0) {
        snprintf(out, out_sz, "%s", we.we_wordv[0]);
        wordfree(&we);
    } else {
        snprintf(out, out_sz, "%s", in);
    }
}

static void set_settings_defaults(settings_t *s) {
    s->sample_rate = 48000;
    s->channels = 2;
    s->max_voices = 12;
    snprintf(s->cache_dir, PATH_LEN, "%s", "~/.cache/bspwm-sounds");
    s->idle_shutdown_ms = 4000;
    s->master_volume = 1.0f;
    snprintf(s->ffmpeg_path, PATH_LEN, "%s", "ffmpeg");
    s->global_min_gap_ms = 0;
}

static rule_t *new_rule(config_t *cfg, const char *name) {
    if (cfg->rule_count >= MAX_RULES) return NULL;
    rule_t *r = &cfg->rules[cfg->rule_count++];
    memset(r, 0, sizeof(*r));
    snprintf(r->name, NAME_LEN, "%s", name);
    r->volume = 1.0f;
    r->priority = 0;
    r->debounce_ms = 0;
    r->max_instances = 0;
    r->suppress_window_ms = 0;
    return r;
}

static int compile_pattern(regex_t *re, const char *pat) {
    return regcomp(re, pat, REG_EXTENDED | REG_ICASE | REG_NOSUB) == 0;
}

static void split_csv(const char *val, char out[][NAME_LEN], int max, int *count) {
    char buf[512];
    snprintf(buf, sizeof(buf), "%s", val);
    *count = 0;
    char *tok = strtok(buf, ",");
    while (tok && *count < max) {
        while (isspace((unsigned char)*tok)) tok++;
        char *end = tok + strlen(tok) - 1;
        while (end > tok && isspace((unsigned char)*end)) *end-- = '\0';
        snprintf(out[*count], NAME_LEN, "%s", tok);
        (*count)++;
        tok = strtok(NULL, ",");
    }
}

int config_load(const char *path, config_t *cfg) {
    FILE *f = fopen(path, "r");
    if (!f) {
        fprintf(stderr, "bspwm-sounds: cannot open config '%s': %m\n", path);
        return -1;
    }

    memset(cfg, 0, sizeof(*cfg));
    set_settings_defaults(&cfg->settings);

    enum { SEC_NONE, SEC_SETTINGS, SEC_SOUNDS, SEC_RULE } section = SEC_NONE;
    rule_t *cur_rule = NULL;

    char line[1024];
    int lineno = 0;
    while (fgets(line, sizeof(line), f)) {
        lineno++;
        char *nl = strchr(line, '\n');
        if (nl) *nl = '\0';

        /* strip comments (# not inside quotes, kept simple: config values are paths/patterns, rarely need '#') */
        char *hash = strchr(line, '#');
        if (hash) *hash = '\0';

        trim(line);
        if (line[0] == '\0') continue;

        if (line[0] == '[') {
            char *close = strchr(line, ']');
            if (!close) {
                fprintf(stderr, "bspwm-sounds: config line %d: malformed section\n", lineno);
                continue;
            }
            *close = '\0';
            char *sec = line + 1;
            trim(sec);

            if (strcmp(sec, "settings") == 0) {
                section = SEC_SETTINGS;
            } else if (strcmp(sec, "sounds") == 0) {
                section = SEC_SOUNDS;
            } else if (strncmp(sec, "rule:", 5) == 0) {
                section = SEC_RULE;
                cur_rule = new_rule(cfg, sec + 5);
                if (!cur_rule) {
                    fprintf(stderr, "bspwm-sounds: too many rules, ignoring '%s'\n", sec + 5);
                }
            } else {
                fprintf(stderr, "bspwm-sounds: config line %d: unknown section [%s]\n", lineno, sec);
                section = SEC_NONE;
            }
            continue;
        }

        char *eq = strchr(line, '=');
        if (!eq) {
            fprintf(stderr, "bspwm-sounds: config line %d: expected key = value\n", lineno);
            continue;
        }
        *eq = '\0';
        char *key = line;
        char *val = eq + 1;
        trim(key);
        trim(val);

        switch (section) {
        case SEC_SETTINGS: {
            settings_t *s = &cfg->settings;
            if (strcmp(key, "sample_rate") == 0) s->sample_rate = atoi(val);
            else if (strcmp(key, "channels") == 0) s->channels = atoi(val);
            else if (strcmp(key, "max_voices") == 0) s->max_voices = atoi(val);
            else if (strcmp(key, "cache_dir") == 0) snprintf(s->cache_dir, PATH_LEN, "%s", val);
            else if (strcmp(key, "idle_shutdown_ms") == 0) s->idle_shutdown_ms = atoi(val);
            else if (strcmp(key, "master_volume") == 0) s->master_volume = (float)atof(val);
            else if (strcmp(key, "ffmpeg_path") == 0) snprintf(s->ffmpeg_path, PATH_LEN, "%s", val);
            else if (strcmp(key, "global_min_gap_ms") == 0) s->global_min_gap_ms = atoi(val);
            else fprintf(stderr, "bspwm-sounds: config line %d: unknown setting '%s'\n", lineno, key);
            break;
        }
        case SEC_SOUNDS: {
            if (cfg->sound_count >= MAX_SOUNDS) {
                fprintf(stderr, "bspwm-sounds: too many sounds defined, ignoring '%s'\n", key);
                break;
            }
            sound_def_t *sd = &cfg->sounds[cfg->sound_count++];
            snprintf(sd->alias, NAME_LEN, "%s", key);
            char expanded[PATH_LEN];
            expand_path(val, expanded, sizeof(expanded));
            snprintf(sd->src_path, PATH_LEN, "%s", expanded);
            break;
        }
        case SEC_RULE: {
            if (!cur_rule) break;
            if (strcmp(key, "event") == 0) snprintf(cur_rule->event, NAME_LEN, "%s", val);
            else if (strcmp(key, "sound") == 0) snprintf(cur_rule->sound_alias, NAME_LEN, "%s", val);
            else if (strcmp(key, "volume") == 0) cur_rule->volume = (float)atof(val);
            else if (strcmp(key, "priority") == 0) cur_rule->priority = atoi(val);
            else if (strcmp(key, "debounce_ms") == 0) cur_rule->debounce_ms = atoi(val);
            else if (strcmp(key, "max_instances") == 0) cur_rule->max_instances = atoi(val);
            else if (strcmp(key, "suppress_window_ms") == 0) cur_rule->suppress_window_ms = atoi(val);
            else if (strcmp(key, "suppress_if_events") == 0) {
                split_csv(val, cur_rule->suppress_if_events, MAX_SUPPRESS, &cur_rule->suppress_count);
            } else if (strcmp(key, "class") == 0) {
                snprintf(cur_rule->class_pat, PAT_LEN, "%s", val);
                cur_rule->has_class = compile_pattern(&cur_rule->class_re, val);
                if (!cur_rule->has_class)
                    fprintf(stderr, "bspwm-sounds: config line %d: bad regex for class\n", lineno);
            } else if (strcmp(key, "instance") == 0) {
                snprintf(cur_rule->instance_pat, PAT_LEN, "%s", val);
                cur_rule->has_instance = compile_pattern(&cur_rule->instance_re, val);
                if (!cur_rule->has_instance)
                    fprintf(stderr, "bspwm-sounds: config line %d: bad regex for instance\n", lineno);
            } else if (strcmp(key, "title") == 0) {
                snprintf(cur_rule->title_pat, PAT_LEN, "%s", val);
                cur_rule->has_title = compile_pattern(&cur_rule->title_re, val);
                if (!cur_rule->has_title)
                    fprintf(stderr, "bspwm-sounds: config line %d: bad regex for title\n", lineno);
            } else {
                fprintf(stderr, "bspwm-sounds: config line %d: unknown rule key '%s'\n", lineno, key);
            }
            break;
        }
        default:
            fprintf(stderr, "bspwm-sounds: config line %d: key outside of any section\n", lineno);
        }
    }

    fclose(f);

    char cache_expanded[PATH_LEN];
    expand_path(cfg->settings.cache_dir, cache_expanded, sizeof(cache_expanded));
    snprintf(cfg->settings.cache_dir, PATH_LEN, "%s", cache_expanded);

    return 0;
}

sound_def_t *config_find_sound(config_t *cfg, const char *alias) {
    for (int i = 0; i < cfg->sound_count; i++) {
        if (strcmp(cfg->sounds[i].alias, alias) == 0) return &cfg->sounds[i];
    }
    return NULL;
}
