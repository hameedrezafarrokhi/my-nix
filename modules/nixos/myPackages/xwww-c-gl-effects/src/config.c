#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <getopt.h>
#include <pwd.h>
#include <unistd.h>

xwww_opts_t opts_defaults(void) {
    xwww_opts_t o;
    memset(&o, 0, sizeof(o));
    o.frames = 20;
    o.duration_ms = 500;
    o.fps_cap = 120;
    o.easing = EASE_OUT_CUBIC;
    o.bezier[0] = 0.42; o.bezier[1] = 0.0; o.bezier[2] = 0.58; o.bezier[3] = 1.0; /* CSS ease-in-out */
    strcpy(o.animation, "fade");
    o.use_random = 0;
    o.scale_mode = SCALE_FILL;
    o.bg_color = 0xFF000000; /* opaque black */
    o.render_scale = 1.0;
    o.threads = 0;
    strcpy(o.output, "all");
    o.tp = tparams_defaults();
    o.slideshow_interval = 300;
    return o;
}

static char *trim(char *s) {
    while (isspace((unsigned char)*s)) s++;
    if (*s == 0) return s;
    char *e = s + strlen(s) - 1;
    while (e > s && isspace((unsigned char)*e)) *e-- = 0;
    return s;
}

static char *strip_quotes(char *s) {
    size_t n = strlen(s);
    if (n >= 2 && ((s[0] == '"' && s[n - 1] == '"') || (s[0] == '\'' && s[n - 1] == '\''))) {
        s[n - 1] = 0;
        s++;
    }
    return s;
}

static uint32_t parse_color(const char *s) {
    /* accepts "#RRGGBB", "#AARRGGBB", or "RRGGBB" */
    if (*s == '#') s++;
    unsigned long v = strtoul(s, NULL, 16);
    if (strlen(s) <= 6) v |= 0xFF000000UL; /* assume opaque if no alpha given */
    return (uint32_t)v;
}

/* Parses "a,b,c,d" into out[0..3]. Returns 0 on success. */
static int parse_4doubles(const char *s, double out[4]) {
    char *copy = strdup(s);
    char *tok = strtok(copy, ",");
    int n = 0;
    while (tok && n < 4) {
        out[n++] = atof(trim(tok));
        tok = strtok(NULL, ",");
    }
    free(copy);
    return n == 4 ? 0 : -1;
}

static void apply_easing_value(xwww_opts_t *o, char *val) {
    /* Accepts either a named preset, or "bezier(x1,y1,x2,y2)" /
     * "cubic-bezier(x1,y1,x2,y2)" directly as the EASING value. */
    char *paren = strchr(val, '(');
    if (paren && strncasecmp(val, "bezier", 6) == 0) {
        *strchr(paren, ')') = 0;
        if (parse_4doubles(paren + 1, o->bezier) == 0) o->easing = EASE_CUSTOM_BEZIER;
        return;
    }
    if (strncasecmp(val, "cubic-bezier", 12) == 0 && paren) {
        *strchr(paren, ')') = 0;
        if (parse_4doubles(paren + 1, o->bezier) == 0) o->easing = EASE_CUSTOM_BEZIER;
        return;
    }
    o->easing = easing_from_name(val);
}

static void apply_kv(xwww_opts_t *o, const char *key, char *val) {
    val = strip_quotes(trim(val));
    if (strcasecmp(key, "ANIMATION") == 0) { strncpy(o->animation, val, sizeof(o->animation) - 1); }
    else if (strcasecmp(key, "RND") == 0 || strcasecmp(key, "RANDOM") == 0) {
        strncpy(o->random_list, val, sizeof(o->random_list) - 1);
        o->use_random = val[0] != 0;
    }
    else if (strcasecmp(key, "FRAMES") == 0) { o->frames = atoi(val); o->duration_ms = 0; }
    else if (strcasecmp(key, "DURATION_MS") == 0 || strcasecmp(key, "DURATION") == 0) o->duration_ms = atof(val);
    else if (strcasecmp(key, "SLEEP") == 0) {
        double sleep_s = atof(val);
        if (o->frames > 0) o->duration_ms = sleep_s * 1000.0 * o->frames;
    }
    else if (strcasecmp(key, "FPS_CAP") == 0 || strcasecmp(key, "FPS") == 0) o->fps_cap = atof(val);
    else if (strcasecmp(key, "EASING") == 0) apply_easing_value(o, val);
    else if (strcasecmp(key, "BEZIER") == 0) {
        if (parse_4doubles(val, o->bezier) == 0) o->easing = EASE_CUSTOM_BEZIER;
    }
    else if (strcasecmp(key, "SCALE_MODE") == 0 || strcasecmp(key, "MODE") == 0) o->scale_mode = scale_mode_from_name(val);
    else if (strcasecmp(key, "BG_COLOR") == 0) o->bg_color = parse_color(val);
    else if (strcasecmp(key, "RENDER_SCALE") == 0 || strcasecmp(key, "TRANSITION_SCALE") == 0) o->render_scale = atof(val);
    else if (strcasecmp(key, "THREADS") == 0) o->threads = atoi(val);
    else if (strcasecmp(key, "OUTPUT") == 0) strncpy(o->output, val, sizeof(o->output) - 1);
    else if (strcasecmp(key, "WAVE_AMP") == 0) o->tp.wave_amp = atof(val);
    else if (strcasecmp(key, "WAVE_LENGTH") == 0 || strcasecmp(key, "WAVE_LENGHT") == 0) o->tp.wave_length = atof(val);
    else if (strcasecmp(key, "PIXELATE_SIZE") == 0) o->tp.pixelate_size = atoi(val);
    else if (strcasecmp(key, "BLINDS_COUNT") == 0) o->tp.blinds_count = atoi(val);
    else if (strcasecmp(key, "CHECKER_SIZE") == 0) o->tp.checker_size = atoi(val);
    else if (strcasecmp(key, "ORIGIN_X") == 0) o->tp.origin_x_pct = atof(val);
    else if (strcasecmp(key, "ORIGIN_Y") == 0) o->tp.origin_y_pct = atof(val);
    else if (strcasecmp(key, "OBLIQUE_ANGLE") == 0) o->tp.oblique_angle = atof(val);
    else if (strcasecmp(key, "SHARD_SIZE") == 0) o->tp.shard_size = atoi(val);
    else if (strcasecmp(key, "CURL_PCT") == 0) o->tp.curl_pct = atof(val);
    else if (strcasecmp(key, "BURN_PATCHES") == 0) o->tp.burn_patches = atoi(val);
    else if (strcasecmp(key, "BURN_JAGGEDNESS") == 0) o->tp.burn_jaggedness = atof(val);
    else if (strcasecmp(key, "PIVOT_PCT") == 0) o->tp.pivot_pct = atof(val);
    else if (strcasecmp(key, "CUBE_ZOOM") == 0) o->tp.cube_zoom = atof(val);
    else if (strcasecmp(key, "CUBE_SPIN_SPEED") == 0) o->tp.cube_spin_speed = atof(val);
    else if (strcasecmp(key, "AXISSPIN_VERTICAL") == 0)
        o->tp.axisspin_vertical = (strcasecmp(val, "true") == 0 || strcmp(val, "1") == 0 || strcasecmp(val, "yes") == 0);
    else if (strcasecmp(key, "AXISSPIN_TURNS") == 0) o->tp.axisspin_turns = atof(val);
    else if (strcasecmp(key, "RIPPLE_AMP") == 0) o->tp.ripple_amp = atof(val);
    else if (strcasecmp(key, "RIPPLE_FREQ") == 0) o->tp.ripple_freq = atof(val);
    else if (strcasecmp(key, "RIPPLE_DROPLETS") == 0) o->tp.ripple_droplets = atoi(val);
    else if (strcasecmp(key, "FLICKER_MIN_BRIGHTNESS") == 0) o->tp.flicker_min_brightness = atof(val);
    else if (strcasecmp(key, "FLICKER_COUNT") == 0) o->tp.flicker_count = atoi(val);
    else if (strcasecmp(key, "LOGO_PATH") == 0) strncpy(o->logo_path, val, sizeof(o->logo_path) - 1);
    else if (strcasecmp(key, "LOGO_SOUND") == 0) strncpy(o->logo_sound, val, sizeof(o->logo_sound) - 1);
    else if (strcasecmp(key, "LOGO_STATIC_FRAC") == 0) o->tp.logo_static_frac = atof(val);
    else if (strcasecmp(key, "LOGO_FADEIN_FRAC") == 0) o->tp.logo_fadein_frac = atof(val);
    else if (strcasecmp(key, "LOGO_SPIN_SPEED") == 0) o->tp.logo_spin_speed = atof(val);
    else if (strcasecmp(key, "LOGO_ZOOM_SPEED") == 0) o->tp.logo_zoom_speed = atof(val);
    else if (strcasecmp(key, "SLIDESHOW_INTERVAL") == 0 || strcasecmp(key, "INTERVAL") == 0) o->slideshow_interval = atof(val);
    else if (strcasecmp(key, "SLIDESHOW_SHUFFLE") == 0 || strcasecmp(key, "SHUFFLE") == 0)
        o->slideshow_shuffle = (strcasecmp(val, "true") == 0 || strcmp(val, "1") == 0 || strcasecmp(val, "yes") == 0);
    /* R_X / R_Y / TRANSITION_CMD / FINAL_CMD / FORMAT / ACCEL from the old
     * bash config are intentionally accepted-and-ignored so an old xwwwrc
     * doesn't hard-error; they no longer apply now that there is no ffmpeg
     * or external setter in the pipeline. */
}

static void expand_home(char *out, size_t outsz, const char *path) {
    if (path[0] == '~') {
        const char *home = getenv("HOME");
        if (!home) { struct passwd *pw = getpwuid(getuid()); home = pw ? pw->pw_dir : ""; }
        snprintf(out, outsz, "%s%s", home, path + 1);
    } else {
        strncpy(out, path, outsz - 1);
        out[outsz - 1] = 0;
    }
}

static void resolve_config_path(xwww_opts_t *o, const char *explicit_path) {
    char path[4096];
    if (explicit_path && *explicit_path) {
        expand_home(path, sizeof(path), explicit_path);
    } else {
        const char *xdg = getenv("XDG_CONFIG_HOME");
        const char *home = getenv("HOME");
        if (xdg && *xdg) snprintf(path, sizeof(path), "%s/xwww/xwwwrc", xdg);
        else snprintf(path, sizeof(path), "%s/.config/xwww/xwwwrc", home ? home : ".");
    }
    strncpy(o->config_path, path, sizeof(o->config_path) - 1);
}

int config_load(xwww_opts_t *o, const char *explicit_path) {
    resolve_config_path(o, explicit_path);

    FILE *f = fopen(o->config_path, "r");
    if (!f) return 0; /* not fatal: defaults + CLI flags still work */

    char line[1024];
    int in_section = 0; /* only apply keys at global scope here */
    while (fgets(line, sizeof(line), f)) {
        char *s = trim(line);
        if (*s == 0 || *s == '#' || *s == ';') continue;
        if (s[0] == '[') {
            in_section = 1; /* per-effect sections are handled separately */
            continue;
        }
        if (in_section) continue;
        char *eq = strchr(s, '=');
        if (!eq) continue;
        *eq = 0;
        char *key = trim(s);
        char *val = eq + 1;
        apply_kv(o, key, val);
    }
    fclose(f);
    return 0;
}

void config_apply_effect_section(xwww_opts_t *o, const char *effect_name) {
    if (!o->config_path[0]) return;
    FILE *f = fopen(o->config_path, "r");
    if (!f) return;

    char line[1024];
    int in_target = 0;
    while (fgets(line, sizeof(line), f)) {
        char *s = trim(line);
        if (*s == 0 || *s == '#' || *s == ';') continue;
        if (s[0] == '[') {
            char *end = strchr(s, ']');
            if (end) { *end = 0; in_target = (strcasecmp(s + 1, effect_name) == 0); }
            continue;
        }
        if (!in_target) continue;
        char *eq = strchr(s, '=');
        if (!eq) continue;
        *eq = 0;
        char *key = trim(s);
        char *val = eq + 1;
        apply_kv(o, key, val);
    }
    fclose(f);
}

static void print_usage(const char *argv0) {
    printf(
        "usage: %s [<image-file-or-directory>] [options]\n"
        "\n"
        "  A bare image path sets that wallpaper. A directory picks a random\n"
        "  image from it. With no path, xwww re-runs the last wallpaper/effect\n"
        "  from $HOME/.xwww-bg (like `sh ~/.fehbg` for feh).\n"
        "\n"
        "transition options:\n"
        "  -a, --animation NAME     transition to use (see --list)\n"
        "  -r, --random [LIST]      pick a random transition, optionally from\n"
        "                           a comma-separated LIST (e.g. wave,fade)\n"
        "  -f, --frames N           frame count (legacy timing mode)\n"
        "  -d, --duration MS        total transition duration in milliseconds\n"
        "      --fps N              cap frames per second (0 = uncapped)\n"
        "  -e, --easing NAME        linear|ease-in-quad|...|ease-in-out-cubic|\n"
        "                           ease-in-sine|...|ease-in-expo|...|\n"
        "                           ease-in-back|...|ease-in-elastic|\n"
        "                           ease-out-elastic|ease-in-bounce|...\n"
        "                           (see --list-easings for the full set)\n"
        "      --bezier X1,Y1,X2,Y2 custom cubic-bezier easing (CSS-style);\n"
        "                           implies --easing bezier\n"
        "\n"
        "placement options:\n"
        "  -s, --scale-mode MODE    fill|fit|stretch|center|tile\n"
        "      --bg-color '#RRGGBB' padding color for fit/center/tile\n"
        "  -o, --output NAME        monitor name, or 'all' (default)\n"
        "\n"
        "per-effect fine control:\n"
        "      --origin-x PCT       origin x for circle/diamond/clock/burn, 0-100\n"
        "                           (0=left, 50=center, 100=right)\n"
        "      --origin-y PCT       origin y, 0=top, 50=center, 100=bottom\n"
        "      --oblique-angle DEG  sweep angle for oblique-left/right (default 45)\n"
        "      --wave-amp N / --wave-length N / --pixelate-size N /\n"
        "      --blinds-count N / --checker-size N / --shard-size N /\n"
        "      --curl-pct N         per-effect tuning (see README)\n"
        "      --origin-x/--origin-y/--oblique-angle/--pivot-pct/\n"
        "      --burn-patches/--burn-jaggedness/--cube-zoom/\n"
        "      --cube-spin-speed/--axisspin-vertical/--axisspin-turns/\n"
        "      --ripple-amp/--ripple-freq/--ripple-droplets/\n"
        "      --flicker-min-brightness/--flicker-count\n"
        "                           more per-effect tuning (see README)\n"
        "      --logo-path PATH     image (file or dir) for the logo-sting effect\n"
        "      --logo-sound PATH    optional sound to play once when it starts\n"
        "      --logo-static-frac/--logo-fadein-frac/--logo-spin-speed/\n"
        "      --logo-zoom-speed    logo-sting timing (see README)\n"
        "      per-effect overrides also work from the config file via\n"
        "      [effect-name] sections -- see config/xwwwrc.example\n"
        "\n"
        "performance:\n"
        "      --tscale FLOAT       render animation frames at this fraction of\n"
        "                           full resolution, upscale for display; final\n"
        "                           frame is always full quality (perf knob)\n"
        "      --threads N          worker threads for frame rendering (0=auto)\n"
        "\n"
        "slideshow / daemon-style mode:\n"
        "      --slideshow DIR      cycle wallpapers from DIR at --interval\n"
        "      --interval SECONDS   time between changes (default 300)\n"
        "      --shuffle            random order instead of sequential\n"
        "      --daemonize          fork to background, pidfile at\n"
        "                           $HOME/.xwww-slideshow.pid\n"
        "      --slideshow-stop     stop a --daemonize'd slideshow\n"
        "\n"
        "other:\n"
        "  -c, --config PATH        use this config file instead of the default\n"
        "      --restore            re-set $HOME/.xwww-bg's wallpaper instantly,\n"
        "                           no transition (use this at login/boot)\n"
        "      --no-save            don't update $HOME/.xwww-bg this run\n"
        "  -l, --list               list all available transitions and exit\n"
        "      --list-easings       list all available easing presets and exit\n"
        "  -v, --version            print version and exit\n"
        "  -h, --help               this help\n",
        argv0);
}

int config_parse_args(xwww_opts_t *o, int argc, char **argv) {
    static struct option longopts[] = {
        { "animation", required_argument, 0, 'a' },
        { "random", optional_argument, 0, 'r' },
        { "frames", required_argument, 0, 'f' },
        { "duration", required_argument, 0, 'd' },
        { "fps", required_argument, 0, 1001 },
        { "easing", required_argument, 0, 'e' },
        { "bezier", required_argument, 0, 1012 },
        { "scale-mode", required_argument, 0, 's' },
        { "bg-color", required_argument, 0, 1002 },
        { "output", required_argument, 0, 'o' },
        { "tscale", required_argument, 0, 1003 },
        { "threads", required_argument, 0, 1004 },
        { "config", required_argument, 0, 'c' },
        { "restore", no_argument, 0, 1005 },
        { "no-save", no_argument, 0, 1006 },
        { "wave-amp", required_argument, 0, 1007 },
        { "wave-length", required_argument, 0, 1008 },
        { "pixelate-size", required_argument, 0, 1009 },
        { "blinds-count", required_argument, 0, 1010 },
        { "checker-size", required_argument, 0, 1011 },
        { "origin-x", required_argument, 0, 1013 },
        { "origin-y", required_argument, 0, 1014 },
        { "oblique-angle", required_argument, 0, 1015 },
        { "shard-size", required_argument, 0, 1016 },
        { "curl-pct", required_argument, 0, 1017 },
        { "burn-patches", required_argument, 0, 1024 },
        { "burn-jaggedness", required_argument, 0, 1025 },
        { "pivot-pct", required_argument, 0, 1026 },
        { "cube-zoom", required_argument, 0, 1027 },
        { "cube-spin-speed", required_argument, 0, 1028 },
        { "axisspin-vertical", no_argument, 0, 1029 },
        { "axisspin-turns", required_argument, 0, 1030 },
        { "ripple-amp", required_argument, 0, 1031 },
        { "ripple-freq", required_argument, 0, 1032 },
        { "ripple-droplets", required_argument, 0, 1033 },
        { "flicker-min-brightness", required_argument, 0, 1034 },
        { "flicker-count", required_argument, 0, 1035 },
        { "logo-path", required_argument, 0, 1036 },
        { "logo-sound", required_argument, 0, 1037 },
        { "logo-static-frac", required_argument, 0, 1038 },
        { "logo-fadein-frac", required_argument, 0, 1039 },
        { "logo-spin-speed", required_argument, 0, 1040 },
        { "logo-zoom-speed", required_argument, 0, 1041 },
        { "slideshow", required_argument, 0, 1018 },
        { "interval", required_argument, 0, 1019 },
        { "shuffle", no_argument, 0, 1020 },
        { "daemonize", no_argument, 0, 1021 },
        { "slideshow-stop", no_argument, 0, 1022 },
        { "list-easings", no_argument, 0, 1023 },
        { "list", no_argument, 0, 'l' },
        { "version", no_argument, 0, 'v' },
        { "help", no_argument, 0, 'h' },
        { 0, 0, 0, 0 }
    };

    /* pull out a leading positional path first, if any (mirrors the old
     * script's `xwww <path> [flags...]` calling convention) */
    if (argc > 1 && argv[1][0] != '-') {
        strncpy(o->target, argv[1], sizeof(o->target) - 1);
        optind = 2;
    } else {
        optind = 1;
    }

    int c;
    while ((c = getopt_long(argc, argv, "a:r::f:d:e:s:o:c:lvh", longopts, NULL)) != -1) {
        switch (c) {
            case 'a': strncpy(o->animation, optarg, sizeof(o->animation) - 1); o->use_random = 0; break;
            case 'r':
                o->use_random = 1;
                if (optarg) strncpy(o->random_list, optarg, sizeof(o->random_list) - 1);
                break;
            case 'f': o->frames = atoi(optarg); o->duration_ms = 0; break;
            case 'd': o->duration_ms = atof(optarg); break;
            case 1001: o->fps_cap = atof(optarg); break;
            case 'e': apply_easing_value(o, optarg); break;
            case 1012: if (parse_4doubles(optarg, o->bezier) == 0) o->easing = EASE_CUSTOM_BEZIER; break;
            case 's': o->scale_mode = scale_mode_from_name(optarg); break;
            case 1002: o->bg_color = parse_color(optarg); break;
            case 'o': strncpy(o->output, optarg, sizeof(o->output) - 1); break;
            case 1003: o->render_scale = atof(optarg); break;
            case 1004: o->threads = atoi(optarg); break;
            case 'c': strncpy(o->config_path, optarg, sizeof(o->config_path) - 1); break;
            case 1005: o->restore_mode = 1; break;
            case 1006: o->no_save = 1; break;
            case 1007: o->tp.wave_amp = atof(optarg); break;
            case 1008: o->tp.wave_length = atof(optarg); break;
            case 1009: o->tp.pixelate_size = atoi(optarg); break;
            case 1010: o->tp.blinds_count = atoi(optarg); break;
            case 1011: o->tp.checker_size = atoi(optarg); break;
            case 1013: o->tp.origin_x_pct = atof(optarg); break;
            case 1014: o->tp.origin_y_pct = atof(optarg); break;
            case 1015: o->tp.oblique_angle = atof(optarg); break;
            case 1016: o->tp.shard_size = atoi(optarg); break;
            case 1017: o->tp.curl_pct = atof(optarg); break;
            case 1024: o->tp.burn_patches = atoi(optarg); break;
            case 1025: o->tp.burn_jaggedness = atof(optarg); break;
            case 1026: o->tp.pivot_pct = atof(optarg); break;
            case 1027: o->tp.cube_zoom = atof(optarg); break;
            case 1028: o->tp.cube_spin_speed = atof(optarg); break;
            case 1029: o->tp.axisspin_vertical = 1; break;
            case 1030: o->tp.axisspin_turns = atof(optarg); break;
            case 1031: o->tp.ripple_amp = atof(optarg); break;
            case 1032: o->tp.ripple_freq = atof(optarg); break;
            case 1033: o->tp.ripple_droplets = atoi(optarg); break;
            case 1034: o->tp.flicker_min_brightness = atof(optarg); break;
            case 1035: o->tp.flicker_count = atoi(optarg); break;
            case 1036: strncpy(o->logo_path, optarg, sizeof(o->logo_path) - 1); break;
            case 1037: strncpy(o->logo_sound, optarg, sizeof(o->logo_sound) - 1); break;
            case 1038: o->tp.logo_static_frac = atof(optarg); break;
            case 1039: o->tp.logo_fadein_frac = atof(optarg); break;
            case 1040: o->tp.logo_spin_speed = atof(optarg); break;
            case 1041: o->tp.logo_zoom_speed = atof(optarg); break;
            case 1018: strncpy(o->slideshow_dir, optarg, sizeof(o->slideshow_dir) - 1); break;
            case 1019: o->slideshow_interval = atof(optarg); break;
            case 1020: o->slideshow_shuffle = 1; break;
            case 1021: o->slideshow_daemonize = 1; break;
            case 1022: o->slideshow_stop = 1; break;
            case 1023: {
                for (int i = 0; i < EASE_COUNT; i++) printf("%s\n", easing_name((easing_t)i));
                exit(0);
            }
            case 'l': o->list_only = 1; break;
            case 'v': o->show_version = 1; break;
            case 'h': o->show_help = 1; print_usage(argv[0]); break;
            default: return -1;
        }
    }
    if (o->render_scale <= 0 || o->render_scale > 1.0) o->render_scale = 1.0;
    return 0;
}
