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
    strcpy(o.animation, "fade");
    o.use_random = 0;
    o.scale_mode = SCALE_FILL;
    o.bg_color = 0xFF000000; /* opaque black */
    o.render_scale = 1.0;
    o.threads = 0;
    strcpy(o.output, "all");
    o.tp = tparams_defaults();
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

static void apply_kv(xwww_opts_t *o, const char *key, char *val) {
    val = strip_quotes(trim(val));
    if (strcasecmp(key, "ANIMATION") == 0) { strncpy(o->animation, val, sizeof(o->animation) - 1); }
    else if (strcasecmp(key, "RND") == 0 || strcasecmp(key, "RANDOM") == 0) {
        strncpy(o->random_list, val, sizeof(o->random_list) - 1);
        o->use_random = val[0] != 0;
    }
    else if (strcasecmp(key, "FRAMES") == 0) { o->frames = atoi(val); o->duration_ms = 0; }
    else if (strcasecmp(key, "DURATION_MS") == 0 || strcasecmp(key, "DURATION") == 0) o->duration_ms = atof(val);
    else if (strcasecmp(key, "SLEEP") == 0) { /* legacy: seconds per frame */
        double sleep_s = atof(val);
        if (o->frames > 0) o->duration_ms = sleep_s * 1000.0 * o->frames;
    }
    else if (strcasecmp(key, "FPS_CAP") == 0 || strcasecmp(key, "FPS") == 0) o->fps_cap = atof(val);
    else if (strcasecmp(key, "EASING") == 0) o->easing = easing_from_name(val);
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

int config_load(xwww_opts_t *o, const char *explicit_path) {
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

    FILE *f = fopen(path, "r");
    if (!f) return 0; /* not fatal: defaults + CLI flags still work */

    char line[1024];
    while (fgets(line, sizeof(line), f)) {
        char *s = trim(line);
        if (*s == 0 || *s == '#' || *s == ';') continue;
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

static void print_usage(const char *argv0) {
    printf(
        "usage: %s [<image-file-or-directory>] [options]\n"
        "\n"
        "  A bare image path sets that wallpaper. A directory picks a random\n"
        "  image from it. With no path, xwww re-runs the last wallpaper/effect\n"
        "  from $HOME/.xwww-bg (like `sh ~/.fehbg` for feh).\n"
        "\n"
        "options:\n"
        "  -a, --animation NAME     transition to use (see --list)\n"
        "  -r, --random [LIST]      pick a random transition, optionally from\n"
        "                           a comma-separated LIST (e.g. wave,fade)\n"
        "  -f, --frames N           frame count (legacy timing mode)\n"
        "  -d, --duration MS        total transition duration in milliseconds\n"
        "      --fps N              cap frames per second (0 = uncapped)\n"
        "  -e, --easing NAME        linear|ease-in-quad|ease-out-quad|\n"
        "                           ease-in-out-quad|ease-in-cubic|ease-out-cubic|\n"
        "                           ease-in-out-cubic\n"
        "  -s, --scale-mode MODE    fill|fit|stretch|center|tile\n"
        "      --bg-color '#RRGGBB' padding color for fit/center/tile\n"
        "  -o, --output NAME        monitor name, or 'all' (default)\n"
        "      --tscale FLOAT       render animation frames at this fraction of\n"
        "                           full resolution, upscale for display; final\n"
        "                           frame is always full quality (perf knob)\n"
        "      --threads N          worker threads for frame rendering (0=auto)\n"
        "  -c, --config PATH        use this config file instead of the default\n"
        "      --restore            re-set $HOME/.xwww-bg's wallpaper instantly,\n"
        "                           no transition (use this at login/boot)\n"
        "      --no-save            don't update $HOME/.xwww-bg this run\n"
        "      --wave-amp N / --wave-length N / --pixelate-size N /\n"
        "      --blinds-count N / --checker-size N\n"
        "                           per-effect tuning\n"
        "  -l, --list               list all available transitions and exit\n"
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
            case 'e': o->easing = easing_from_name(optarg); break;
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
            case 'l': o->list_only = 1; break;
            case 'v': o->show_version = 1; break;
            case 'h': o->show_help = 1; print_usage(argv[0]); break;
            default: return -1;
        }
    }
    if (o->render_scale <= 0 || o->render_scale > 1.0) o->render_scale = 1.0;
    return 0;
}
