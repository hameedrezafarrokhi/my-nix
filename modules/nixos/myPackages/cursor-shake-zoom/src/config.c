#include "config.h"
#include "svg_loader.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <strings.h>
#include <getopt.h>
#include <unistd.h>
#include <pwd.h>

static const char *VERSION = "1.0.0";

void config_default_path(char *buf, size_t buflen) {
    const char *xdg = getenv("XDG_CONFIG_HOME");
    if (xdg && *xdg) {
        snprintf(buf, buflen, "%s/cursor-scaler/config.conf", xdg);
        return;
    }
    const char *home = getenv("HOME");
    if (!home) {
        struct passwd *pw = getpwuid(getuid());
        home = pw ? pw->pw_dir : "/tmp";
    }
    snprintf(buf, buflen, "%s/.config/cursor-scaler/config.conf", home);
}

EasingType easing_from_string(const char *s) {
    if (!s) return EASE_CUBIC_OUT;
    if (!strcasecmp(s, "linear"))          return EASE_LINEAR;
    if (!strcasecmp(s, "quad-in"))         return EASE_QUAD_IN;
    if (!strcasecmp(s, "quad-out"))        return EASE_QUAD_OUT;
    if (!strcasecmp(s, "quad-in-out"))     return EASE_QUAD_IN_OUT;
    if (!strcasecmp(s, "cubic-in"))        return EASE_CUBIC_IN;
    if (!strcasecmp(s, "cubic-out"))       return EASE_CUBIC_OUT;
    if (!strcasecmp(s, "cubic-in-out"))    return EASE_CUBIC_IN_OUT;
    if (!strcasecmp(s, "expo-out"))        return EASE_EXPO_OUT;
    if (!strcasecmp(s, "back-out"))        return EASE_BACK_OUT;
    fprintf(stderr, "cursor-scaler: unknown easing '%s', falling back to cubic-out\n", s);
    return EASE_CUBIC_OUT;
}

const char *easing_to_string(EasingType e) {
    switch (e) {
        case EASE_LINEAR:       return "linear";
        case EASE_QUAD_IN:      return "quad-in";
        case EASE_QUAD_OUT:     return "quad-out";
        case EASE_QUAD_IN_OUT:  return "quad-in-out";
        case EASE_CUBIC_IN:     return "cubic-in";
        case EASE_CUBIC_OUT:    return "cubic-out";
        case EASE_CUBIC_IN_OUT: return "cubic-in-out";
        case EASE_EXPO_OUT:     return "expo-out";
        case EASE_BACK_OUT:     return "back-out";
    }
    return "cubic-out";
}

static const char *shape_mode_to_string(ShapeMode m) {
    switch (m) {
        case SHAPE_AUTO:      return "auto";
        case SHAPE_FORCE_ON:  return "on";
        case SHAPE_FORCE_OFF: return "off";
    }
    return "auto";
}

static ShapeMode shape_mode_from_string(const char *s) {
    if (!strcasecmp(s, "on") || !strcasecmp(s, "force") || !strcasecmp(s, "true"))  return SHAPE_FORCE_ON;
    if (!strcasecmp(s, "off") || !strcasecmp(s, "false")) return SHAPE_FORCE_OFF;
    return SHAPE_AUTO;
}

void config_set_defaults(Config *cfg) {
    memset(cfg, 0, sizeof(*cfg));

    cfg->shake_threshold    = 8;
    cfg->shake_timeout      = 0.3;
    cfg->movement_threshold = 5.0;

    cfg->min_scale    = 1.0;
    cfg->max_scale    = 30.0;
    cfg->zoom_in_rate = 6.0; /* scale units/sec while shaking - always linear */

    cfg->zoom_out_duration = 0.18;
    cfg->easing             = EASE_CUBIC_OUT;
    cfg->fps                = 60;

    cfg->disable_in_fullscreen = 1;

    snprintf(cfg->cursor_name, sizeof(cfg->cursor_name), "left_ptr");
    cfg->cursor_theme[0] = '\0';
    cfg->cursor_size = 0; /* auto = largest available */

    cfg->svg_path[0] = '\0';
    cfg->disable_svg = 0;

    snprintf(cfg->filter, sizeof(cfg->filter), "best");
    cfg->shape_mode = SHAPE_AUTO;

    cfg->config_path[0] = '\0';
}

static char *trim(char *s) {
    while (isspace((unsigned char)*s)) s++;
    if (*s == '\0') return s;
    char *end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) *end-- = '\0';
    return s;
}

int config_load_file(Config *cfg, const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return -1;

    char line[1024];
    int lineno = 0;
    while (fgets(line, sizeof(line), f)) {
        lineno++;
        char *l = trim(line);
        if (*l == '\0' || *l == '#' || *l == ';') continue;

        char *eq = strchr(l, '=');
        if (!eq) {
            fprintf(stderr, "cursor-scaler: %s:%d: ignoring malformed line\n", path, lineno);
            continue;
        }
        *eq = '\0';
        char *key = trim(l);
        char *val = trim(eq + 1);

        /* strip optional surrounding quotes on the value */
        size_t vlen = strlen(val);
        if (vlen >= 2 && ((val[0] == '"' && val[vlen - 1] == '"') ||
                           (val[0] == '\'' && val[vlen - 1] == '\''))) {
            val[vlen - 1] = '\0';
            val++;
        }

        if      (!strcasecmp(key, "shake_threshold"))      cfg->shake_threshold = atoi(val);
        else if (!strcasecmp(key, "shake_timeout"))         cfg->shake_timeout = atof(val);
        else if (!strcasecmp(key, "movement_threshold"))    cfg->movement_threshold = atof(val);
        else if (!strcasecmp(key, "min_scale"))              cfg->min_scale = atof(val);
        else if (!strcasecmp(key, "max_scale"))              cfg->max_scale = atof(val);
        else if (!strcasecmp(key, "zoom_in_rate"))           cfg->zoom_in_rate = atof(val);
        else if (!strcasecmp(key, "zoom_out_duration"))      cfg->zoom_out_duration = atof(val);
        else if (!strcasecmp(key, "easing"))                 cfg->easing = easing_from_string(val);
        else if (!strcasecmp(key, "fps"))                    cfg->fps = atoi(val);
        else if (!strcasecmp(key, "cursor_name"))            snprintf(cfg->cursor_name, sizeof(cfg->cursor_name), "%s", val);
        else if (!strcasecmp(key, "cursor_theme"))           snprintf(cfg->cursor_theme, sizeof(cfg->cursor_theme), "%s", val);
        else if (!strcasecmp(key, "cursor_size"))            cfg->cursor_size = atoi(val);
        else if (!strcasecmp(key, "svg_path"))               snprintf(cfg->svg_path, sizeof(cfg->svg_path), "%s", val);
        else if (!strcasecmp(key, "disable_svg"))            cfg->disable_svg = (!strcasecmp(val, "true") || !strcmp(val, "1"));
        else if (!strcasecmp(key, "filter"))                 snprintf(cfg->filter, sizeof(cfg->filter), "%s", val);
        else if (!strcasecmp(key, "shape_mode"))             cfg->shape_mode = shape_mode_from_string(val);
        else if (!strcasecmp(key, "disable_in_fullscreen"))  cfg->disable_in_fullscreen = (!strcasecmp(val, "true") || !strcmp(val, "1"));
        else fprintf(stderr, "cursor-scaler: %s:%d: unknown key '%s'\n", path, lineno, key);
    }

    fclose(f);
    snprintf(cfg->config_path, sizeof(cfg->config_path), "%s", path);
    return 0;
}

static void print_usage(const char *prog) {
    printf(
        "Usage: %s [options]\n"
        "\n"
        "Shake the mouse cursor to magnify it (X11).\n"
        "\n"
        "Shake detection:\n"
        "  --shake-threshold N        direction reversals to trigger a zoom (default 8)\n"
        "  --shake-timeout SEC        reversal streak reset window (default 0.3)\n"
        "  --movement-threshold PX    minimum motion to count as a direction (default 5)\n"
        "\n"
        "Scaling:\n"
        "  --min-scale F              default 1.0\n"
        "  --max-scale F              default 30.0\n"
        "  --zoom-in-rate F           scale units/sec while shaking; growth is always\n"
        "                             linear and tracks the shake directly (default 6.0)\n"
        "\n"
        "Animation:\n"
        "  --zoom-out-duration SEC    time for the single shrink-back-to-normal\n"
        "                             transition once shaking stops (default 0.18)\n"
        "  --easing NAME              eases the shrink-back transition only:\n"
        "                             linear, quad-in, quad-out, quad-in-out,\n"
        "                             cubic-in, cubic-out, cubic-in-out,\n"
        "                             expo-out, back-out (default cubic-out)\n"
        "  --fps N                    animation frame cap while zooming - match your\n"
        "                             monitor's refresh rate, more is wasted work\n"
        "                             (default 60)\n"
        "\n"
        "Cursor source:\n"
        "  --cursor-name NAME         xcursor name (default left_ptr)\n"
        "  --cursor-theme NAME        xcursor theme (default: $XCURSOR_THEME)\n"
        "  --cursor-size N            base bitmap size, 0 = largest available (default 0)\n"
        "  --svg-path PATH            source SVG for true lossless scaling\n"
        "  --disable-svg              never use SVG rasterization even if available\n"
        "\n"
        "Rendering:\n"
        "  --filter NAME              nearest, bilinear, good, best (default best)\n"
        "  --shape-mode MODE          auto, on, off - XShape window cutout used when\n"
        "                             no compositor is running (default auto)\n"
        "\n"
        "Fullscreen guard:\n"
        "  --disable-in-fullscreen    don't engage while the focused window is\n"
        "                             fullscreen, e.g. a game (default: on)\n"
        "  --enable-in-fullscreen     always engage, even in fullscreen apps\n"
        "\n"
        "General:\n"
        "  --config PATH              load a specific config file\n"
        "  --print-config             print the effective config and exit\n"
        "  --version                  print version and exit\n"
        "  -h, --help                 show this help\n",
        prog);
}

void config_print(const Config *cfg) {
    printf("# effective cursor-scaler configuration\n");
    if (cfg->config_path[0]) printf("# loaded from: %s\n", cfg->config_path);
    printf("shake_threshold = %d\n", cfg->shake_threshold);
    printf("shake_timeout = %.3f\n", cfg->shake_timeout);
    printf("movement_threshold = %.3f\n", cfg->movement_threshold);
    printf("min_scale = %.3f\n", cfg->min_scale);
    printf("max_scale = %.3f\n", cfg->max_scale);
    printf("zoom_in_rate = %.3f\n", cfg->zoom_in_rate);
    printf("zoom_out_duration = %.3f\n", cfg->zoom_out_duration);
    printf("easing = %s (applies to shrink-back only)\n", easing_to_string(cfg->easing));
    printf("fps = %d\n", cfg->fps);
    printf("disable_in_fullscreen = %s\n", cfg->disable_in_fullscreen ? "true" : "false");
    printf("cursor_name = %s\n", cfg->cursor_name);
    printf("cursor_theme = %s\n", cfg->cursor_theme[0] ? cfg->cursor_theme : "(default)");
    printf("cursor_size = %d%s\n", cfg->cursor_size, cfg->cursor_size == 0 ? " (auto)" : "");
    printf("svg_path = %s\n", cfg->svg_path[0] ? cfg->svg_path : "(none)");
    printf("disable_svg = %s\n", cfg->disable_svg ? "true" : "false");
    printf("svg_support_built = %s\n", svg_support_built() ? "true" : "false");
    printf("filter = %s\n", cfg->filter);
    printf("shape_mode = %s\n", shape_mode_to_string(cfg->shape_mode));
}

enum {
    OPT_SHAKE_THRESHOLD = 1000,
    OPT_SHAKE_TIMEOUT,
    OPT_MOVEMENT_THRESHOLD,
    OPT_MIN_SCALE,
    OPT_MAX_SCALE,
    OPT_ZOOM_IN_RATE,
    OPT_ZOOM_OUT_DURATION,
    OPT_EASING,
    OPT_FPS,
    OPT_CURSOR_NAME,
    OPT_CURSOR_THEME,
    OPT_CURSOR_SIZE,
    OPT_SVG_PATH,
    OPT_DISABLE_SVG,
    OPT_FILTER,
    OPT_SHAPE_MODE,
    OPT_DISABLE_IN_FULLSCREEN,
    OPT_ENABLE_IN_FULLSCREEN,
    OPT_CONFIG,
    OPT_PRINT_CONFIG,
    OPT_VERSION,
};

/* returns 0 to continue running, 1 to exit(0), -1 to exit(1) */
int config_parse_args(Config *cfg, int argc, char **argv) {
    static struct option long_opts[] = {
        {"shake-threshold",       required_argument, 0, OPT_SHAKE_THRESHOLD},
        {"shake-timeout",         required_argument, 0, OPT_SHAKE_TIMEOUT},
        {"movement-threshold",    required_argument, 0, OPT_MOVEMENT_THRESHOLD},
        {"min-scale",             required_argument, 0, OPT_MIN_SCALE},
        {"max-scale",             required_argument, 0, OPT_MAX_SCALE},
        {"zoom-in-rate",          required_argument, 0, OPT_ZOOM_IN_RATE},
        {"zoom-out-duration",     required_argument, 0, OPT_ZOOM_OUT_DURATION},
        {"easing",                required_argument, 0, OPT_EASING},
        {"fps",                   required_argument, 0, OPT_FPS},
        {"cursor-name",           required_argument, 0, OPT_CURSOR_NAME},
        {"cursor-theme",          required_argument, 0, OPT_CURSOR_THEME},
        {"cursor-size",           required_argument, 0, OPT_CURSOR_SIZE},
        {"svg-path",              required_argument, 0, OPT_SVG_PATH},
        {"disable-svg",           no_argument,       0, OPT_DISABLE_SVG},
        {"filter",                required_argument, 0, OPT_FILTER},
        {"shape-mode",            required_argument, 0, OPT_SHAPE_MODE},
        {"disable-in-fullscreen", no_argument,       0, OPT_DISABLE_IN_FULLSCREEN},
        {"enable-in-fullscreen",  no_argument,       0, OPT_ENABLE_IN_FULLSCREEN},
        {"config",                required_argument, 0, OPT_CONFIG},
        {"print-config",          no_argument,       0, OPT_PRINT_CONFIG},
        {"version",               no_argument,       0, OPT_VERSION},
        {"help",                  no_argument,       0, 'h'},
        {0, 0, 0, 0}
    };

    /* First pass: only look for --config so it can be loaded before other
     * flags are applied (CLI flags always win over the config file). */
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--config") && i + 1 < argc) {
            config_load_file(cfg, argv[i + 1]);
            break;
        }
    }

    int want_print_config = 0;
    optind = 1;
    int c;
    while ((c = getopt_long(argc, argv, "h", long_opts, NULL)) != -1) {
        switch (c) {
            case OPT_SHAKE_THRESHOLD:      cfg->shake_threshold = atoi(optarg); break;
            case OPT_SHAKE_TIMEOUT:        cfg->shake_timeout = atof(optarg); break;
            case OPT_MOVEMENT_THRESHOLD:   cfg->movement_threshold = atof(optarg); break;
            case OPT_MIN_SCALE:            cfg->min_scale = atof(optarg); break;
            case OPT_MAX_SCALE:            cfg->max_scale = atof(optarg); break;
            case OPT_ZOOM_IN_RATE:         cfg->zoom_in_rate = atof(optarg); break;
            case OPT_ZOOM_OUT_DURATION:    cfg->zoom_out_duration = atof(optarg); break;
            case OPT_EASING:               cfg->easing = easing_from_string(optarg); break;
            case OPT_FPS:                  cfg->fps = atoi(optarg); break;
            case OPT_CURSOR_NAME:          snprintf(cfg->cursor_name, sizeof(cfg->cursor_name), "%s", optarg); break;
            case OPT_CURSOR_THEME:         snprintf(cfg->cursor_theme, sizeof(cfg->cursor_theme), "%s", optarg); break;
            case OPT_CURSOR_SIZE:          cfg->cursor_size = atoi(optarg); break;
            case OPT_SVG_PATH:             snprintf(cfg->svg_path, sizeof(cfg->svg_path), "%s", optarg); break;
            case OPT_DISABLE_SVG:          cfg->disable_svg = 1; break;
            case OPT_FILTER:               snprintf(cfg->filter, sizeof(cfg->filter), "%s", optarg); break;
            case OPT_SHAPE_MODE:           cfg->shape_mode = shape_mode_from_string(optarg); break;
            case OPT_DISABLE_IN_FULLSCREEN:cfg->disable_in_fullscreen = 1; break;
            case OPT_ENABLE_IN_FULLSCREEN: cfg->disable_in_fullscreen = 0; break;
            case OPT_CONFIG:               /* already handled above */ break;
            case OPT_PRINT_CONFIG:         want_print_config = 1; break;
            case OPT_VERSION:
                printf("cursor-scaler %s\n", VERSION);
                return 1;
            case 'h':
                print_usage(argv[0]);
                return 1;
            default:
                print_usage(argv[0]);
                return -1;
        }
    }

    if (want_print_config) {
        config_print(cfg);
        return 1;
    }

    return 0;
}
