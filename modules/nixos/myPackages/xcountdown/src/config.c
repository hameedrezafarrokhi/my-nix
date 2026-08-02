#define _POSIX_C_SOURCE 200809L
#include "config.h"
#include "timefmt.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <getopt.h>
#include <pwd.h>
#include <unistd.h>

void config_set_defaults(config_t *cfg) {
    memset(cfg, 0, sizeof(*cfg));

    cfg->total_seconds = 300; /* 5 minutes */
    snprintf(cfg->format, sizeof(cfg->format), "hh:mm:ss");

    cfg->has_x = cfg->has_y = 0;
    cfg->x = cfg->y = 0;

    snprintf(cfg->font, sizeof(cfg->font), "Sans");
    cfg->font_size = 48;
    snprintf(cfg->color, sizeof(cfg->color), "#ffffff");

    cfg->flash = 0;
    cfg->flash_speed = 5.0;
    cfg->flash_style = FLASH_FADE;

    cfg->animate_when_active = 1;
    cfg->animate_when_paused = 0;
    cfg->animate_all_segments = 1;

    cfg->focus_follow = 1;

    cfg->bg = BG_SHADOW;
    snprintf(cfg->bg_color, sizeof(cfg->bg_color), "#000000aa");
    cfg->bg_size = 0; /* auto */

    cfg->scroll_seconds = 0.0; /* instant digit changes by default */
    cfg->scroll_style = SCROLL_SLIDE;

    cfg->sticky = 1;

    cfg->label[0] = '\0';
    cfg->on_finish_cmd[0] = '\0';

    cfg->exit_on_finish = 0;
    cfg->on_success_cmd[0] = '\0';

    cfg->alarm_path[0] = '\0';
    cfg->alarm_repeat = 1;

    cfg->on_right_click   = (binding_t){ACT_EXIT, 0};
    cfg->on_right_dblclick= (binding_t){ACT_RESET, 0};
    cfg->on_left_click    = (binding_t){ACT_PAUSE, 0};
    cfg->on_left_dblclick = (binding_t){ACT_SURPRISE, 0};
    cfg->on_scroll_up     = (binding_t){ACT_INC, 60};
    cfg->on_scroll_down   = (binding_t){ACT_DEC, 60};

    cfg->config_path[0] = '\0';
}

const char *config_default_path(void) {
    static char path[512];
    const char *xdg = getenv("XDG_CONFIG_HOME");
    if (xdg && *xdg) {
        snprintf(path, sizeof(path), "%s/countdown/countdown.conf", xdg);
        return path;
    }
    const char *home = getenv("HOME");
    if (!home || !*home) {
        struct passwd *pw = getpwuid(getuid());
        if (pw) home = pw->pw_dir;
    }
    if (!home) home = ".";
    snprintf(path, sizeof(path), "%s/.config/countdown/countdown.conf", home);
    return path;
}

int config_parse_binding(const char *str, binding_t *out) {
    if (!str || !*str) return 0;
    char buf[64];
    snprintf(buf, sizeof(buf), "%s", str);
    char *colon = strchr(buf, ':');
    int amount = 0;
    if (colon) {
        *colon = '\0';
        amount = atoi(colon + 1);
    }
    for (char *c = buf; *c; c++) *c = (char)tolower((unsigned char)*c);

    if (strcmp(buf, "none") == 0)          { out->action = ACT_NONE; out->amount = 0; }
    else if (strcmp(buf, "exit") == 0)     { out->action = ACT_EXIT; out->amount = 0; }
    else if (strcmp(buf, "reset") == 0)    { out->action = ACT_RESET; out->amount = 0; }
    else if (strcmp(buf, "pause") == 0)    { out->action = ACT_PAUSE; out->amount = 0; }
    else if (strcmp(buf, "surprise") == 0) { out->action = ACT_SURPRISE; out->amount = 0; }
    else if (strcmp(buf, "drag") == 0)     { out->action = ACT_DRAG; out->amount = 0; }
    else if (strcmp(buf, "inc") == 0)      { out->action = ACT_INC; out->amount = amount > 0 ? amount : 60; }
    else if (strcmp(buf, "dec") == 0)      { out->action = ACT_DEC; out->amount = amount > 0 ? amount : 60; }
    else return 0;
    return 1;
}

static char *trim(char *s) {
    while (isspace((unsigned char)*s)) s++;
    if (*s == '\0') return s;
    char *end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) *end-- = '\0';
    return s;
}

static int truthy(const char *v) {
    return strcasecmp(v, "true") == 0 || strcasecmp(v, "yes") == 0 ||
           strcasecmp(v, "1") == 0 || strcasecmp(v, "on") == 0;
}

static void apply_kv(config_t *cfg, const char *key, const char *val, const char *path, int lineno) {
    if (strcmp(key, "time") == 0) {
        long secs;
        if (timefmt_parse_duration(val, &secs)) cfg->total_seconds = secs;
        else fprintf(stderr, "%s:%d: invalid time '%s'\n", path, lineno, val);
    } else if (strcmp(key, "format") == 0) {
        if (timefmt_validate(val)) snprintf(cfg->format, sizeof(cfg->format), "%s", val);
        else fprintf(stderr, "%s:%d: invalid format '%s'\n", path, lineno, val);
    } else if (strcmp(key, "x") == 0) {
        cfg->x = atoi(val); cfg->has_x = 1;
    } else if (strcmp(key, "y") == 0) {
        cfg->y = atoi(val); cfg->has_y = 1;
    } else if (strcmp(key, "font") == 0) {
        snprintf(cfg->font, sizeof(cfg->font), "%s", val);
    } else if (strcmp(key, "size") == 0) {
        cfg->font_size = atoi(val);
    } else if (strcmp(key, "color") == 0) {
        snprintf(cfg->color, sizeof(cfg->color), "%s", val);
    } else if (strcmp(key, "flash") == 0) {
        cfg->flash = truthy(val);
    } else if (strcmp(key, "flash_speed") == 0 || strcmp(key, "flash-speed") == 0) {
        cfg->flash_speed = atof(val);
    } else if (strcmp(key, "flash_style") == 0 || strcmp(key, "flash-style") == 0) {
        if (strcasecmp(val, "fade") == 0) cfg->flash_style = FLASH_FADE;
        else if (strcasecmp(val, "throb") == 0 || strcasecmp(val, "beat") == 0) cfg->flash_style = FLASH_THROB;
        else if (strcasecmp(val, "blink") == 0) cfg->flash_style = FLASH_BLINK;
        else fprintf(stderr, "%s:%d: invalid flash_style '%s'\n", path, lineno, val);
    } else if (strcmp(key, "animate_when_active") == 0) {
        cfg->animate_when_active = truthy(val);
    } else if (strcmp(key, "animate_when_paused") == 0) {
        cfg->animate_when_paused = truthy(val);
    } else if (strcmp(key, "animate_all_segments") == 0) {
        cfg->animate_all_segments = truthy(val);
    } else if (strcmp(key, "focus_follow") == 0) {
        cfg->focus_follow = truthy(val);
    } else if (strcmp(key, "bg") == 0) {
        if (strcasecmp(val, "none") == 0) cfg->bg = BG_NONE;
        else if (strcasecmp(val, "transparent") == 0) cfg->bg = BG_TRANSPARENT;
        else if (strcasecmp(val, "circle") == 0) cfg->bg = BG_CIRCLE;
        else if (strcasecmp(val, "square") == 0) cfg->bg = BG_SQUARE;
        else if (strcasecmp(val, "shadow") == 0) cfg->bg = BG_SHADOW;
        else fprintf(stderr, "%s:%d: invalid bg '%s'\n", path, lineno, val);
    } else if (strcmp(key, "bg_color") == 0 || strcmp(key, "bg-color") == 0) {
        snprintf(cfg->bg_color, sizeof(cfg->bg_color), "%s", val);
    } else if (strcmp(key, "bg_size") == 0 || strcmp(key, "bg-size") == 0) {
        cfg->bg_size = strcasecmp(val, "auto") == 0 ? 0 : atoi(val);
    } else if (strcmp(key, "scroll") == 0) {
        cfg->scroll_seconds = atof(val);
    } else if (strcmp(key, "scroll_style") == 0 || strcmp(key, "scroll-style") == 0) {
        if (strcasecmp(val, "slide") == 0) cfg->scroll_style = SCROLL_SLIDE;
        else if (strcasecmp(val, "flip") == 0) cfg->scroll_style = SCROLL_FLIP;
        else if (strcasecmp(val, "bounce") == 0) cfg->scroll_style = SCROLL_BOUNCE;
        else fprintf(stderr, "%s:%d: invalid scroll_style '%s'\n", path, lineno, val);
    } else if (strcmp(key, "sticky") == 0 || strcmp(key, "visible_all_desktops") == 0) {
        cfg->sticky = truthy(val);
    } else if (strcmp(key, "label") == 0) {
        snprintf(cfg->label, sizeof(cfg->label), "%s", val);
    } else if (strcmp(key, "on_finish") == 0) {
        snprintf(cfg->on_finish_cmd, sizeof(cfg->on_finish_cmd), "%s", val);
    } else if (strcmp(key, "exit_on_finish") == 0) {
        cfg->exit_on_finish = truthy(val);
    } else if (strcmp(key, "on_success") == 0) {
        snprintf(cfg->on_success_cmd, sizeof(cfg->on_success_cmd), "%s", val);
    } else if (strcmp(key, "alarm") == 0) {
        snprintf(cfg->alarm_path, sizeof(cfg->alarm_path), "%s", val);
    } else if (strcmp(key, "alarm_repeat") == 0) {
        cfg->alarm_repeat = atoi(val);
    } else if (strcmp(key, "click.right") == 0) {
        if (!config_parse_binding(val, &cfg->on_right_click))
            fprintf(stderr, "%s:%d: invalid action '%s'\n", path, lineno, val);
    } else if (strcmp(key, "click.right2") == 0) {
        if (!config_parse_binding(val, &cfg->on_right_dblclick))
            fprintf(stderr, "%s:%d: invalid action '%s'\n", path, lineno, val);
    } else if (strcmp(key, "click.left") == 0) {
        if (!config_parse_binding(val, &cfg->on_left_click))
            fprintf(stderr, "%s:%d: invalid action '%s'\n", path, lineno, val);
    } else if (strcmp(key, "click.left2") == 0) {
        if (!config_parse_binding(val, &cfg->on_left_dblclick))
            fprintf(stderr, "%s:%d: invalid action '%s'\n", path, lineno, val);
    } else if (strcmp(key, "click.scroll_up") == 0) {
        if (!config_parse_binding(val, &cfg->on_scroll_up))
            fprintf(stderr, "%s:%d: invalid action '%s'\n", path, lineno, val);
    } else if (strcmp(key, "click.scroll_down") == 0) {
        if (!config_parse_binding(val, &cfg->on_scroll_down))
            fprintf(stderr, "%s:%d: invalid action '%s'\n", path, lineno, val);
    } else {
        fprintf(stderr, "%s:%d: unknown key '%s'\n", path, lineno, key);
    }
}

int config_load_file(config_t *cfg, const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return 1; /* missing config file is fine, defaults apply */

    char line[1024];
    int lineno = 0;
    while (fgets(line, sizeof(line), f)) {
        lineno++;
        char *s = trim(line);
        if (*s == '\0' || *s == '#' || *s == ';') continue;
        char *eq = strchr(s, '=');
        if (!eq) {
            fprintf(stderr, "%s:%d: expected key=value\n", path, lineno);
            continue;
        }
        *eq = '\0';
        char *key = trim(s);
        char *val = trim(eq + 1);
        /* strip inline comments starting with # (not inside value on purpose;
         * keep it simple since values here are never expected to contain '#') */
        char *hash = strchr(val, '#');
        if (hash) { *hash = '\0'; val = trim(val); }
        apply_kv(cfg, key, val, path, lineno);
    }
    fclose(f);
    return 1;
}

static void print_usage(const char *prog) {
    printf(
"Usage: %s [options]\n"
"\n"
"A lightweight X11 countdown widget.\n"
"\n"
"  -t, --time <duration>       e.g. 5m, 1h30m, 90s, or bare seconds (default 5m)\n"
"      --format <fmt>          hh:mm:ss (default), mm:ss, dd:hh:mm:ss, seconds, ...\n"
"  -x <pixels>                 window x position (negative = from right edge)\n"
"  -y <pixels>                 window y position (negative = from bottom edge)\n"
"      --font <family>         font family name (default Sans)\n"
"      --size <pt>             font size in points (default 48)\n"
"      --color <#rrggbb[aa]>   text color (default #ffffff)\n"
"      --flash                 enable fade in/out animation on the text\n"
"      --flash-speed <1-10>    5 = neutral, <5 slower, >5 faster (default 5)\n"
"      --flash-style <style>   fade (default) | throb | blink\n"
"      --bg <style>            none|transparent|circle|square|shadow (default shadow)\n"
"      --bg-color <#rrggbbaa>  background color (default #000000aa)\n"
"      --bg-size <px|auto>     background size (default auto)\n"
"      --scroll <seconds>      digit transition duration on value change (default 0 = instant)\n"
"      --scroll-style <style>  slide (default) | flip | bounce\n"
"      --sticky                visible on all desktops (default on)\n"
"      --no-sticky              disable sticky behavior\n"
"      --label <text>          optional caption text\n"
"      --on-finish <cmd>       shell command to run once when the timer hits 0\n"
"      --exit-on-finish        quit (exit code 0) once finished (and any alarm ends)\n"
"                              default: off, widget just stays showing 0\n"
"      --on-success <cmd>      shell command run only if this process exits with\n"
"                              code 0 (never runs on right-click cancel/exit-1)\n"
"      --alarm <soundfile>     play a sound when the timer hits 0\n"
"      --alarm-repeat <n>      how many times to play it (default 1); 0 = repeat\n"
"                              until you move the mouse over the widget or press a key\n"
"      --[no-]animate-when-active   run flash/transition animation while counting\n"
"                              down (default: on)\n"
"      --[no-]animate-when-paused   run flash/transition animation while paused\n"
"                              (default: off, animation freezes with the timer)\n"
"      --[no-]focus-follow     take/release input focus on mouse enter/leave\n"
"                              (default: on; turn off if your WM handles this badly)\n"
"      --animate-changed-segment-only   with a format like hh:mm:ss, only the\n"
"                              fastest-changing field (e.g. seconds) pulses with\n"
"                              --flash; minutes/hours stay still (default: all\n"
"                              fields pulse together, i.e. --animate-all-segments)\n"
"      --on-right-click <act>        default: exit\n"
"      --on-right-dblclick <act>     default: reset\n"
"      --on-left-click <act>         default: pause\n"
"      --on-left-dblclick <act>      default: surprise\n"
"      --on-scroll-up <act>          default: inc:60\n"
"      --on-scroll-down <act>        default: dec:60\n"
"                              act is one of: none, exit, reset, pause, surprise,\n"
"                              inc:<seconds>, dec:<seconds>\n"
"  -c, --config <path>         config file path (default ~/.config/countdown/countdown.conf)\n"
"  -h, --help                  show this help and exit\n"
"  -v, --version                show version and exit\n"
"\n"
"Left-click-and-hold always drags the window; this is not remappable.\n"
, prog);
}

enum {
    OPT_FORMAT = 1000, OPT_FONT, OPT_SIZE, OPT_COLOR, OPT_FLASH, OPT_FLASH_SPEED,
    OPT_BG, OPT_BG_COLOR, OPT_BG_SIZE, OPT_SCROLL, OPT_SCROLL_STYLE, OPT_STICKY, OPT_NO_STICKY,
    OPT_LABEL, OPT_ON_FINISH, OPT_ON_RC, OPT_ON_RDC, OPT_ON_LC, OPT_ON_LDC,
    OPT_ON_SU, OPT_ON_SD, OPT_EXIT_ON_FINISH, OPT_ON_SUCCESS, OPT_ALARM, OPT_ALARM_REPEAT,
    OPT_FLASH_STYLE, OPT_ANIM_ACTIVE, OPT_NO_ANIM_ACTIVE, OPT_ANIM_PAUSED, OPT_NO_ANIM_PAUSED,
    OPT_FOCUS_FOLLOW, OPT_NO_FOCUS_FOLLOW, OPT_ANIM_ALL_SEGS, OPT_ANIM_CHANGED_SEG
};

int config_parse_args(config_t *cfg, int argc, char **argv) {
    static struct option long_opts[] = {
        {"time", required_argument, 0, 't'},
        {"format", required_argument, 0, OPT_FORMAT},
        {"font", required_argument, 0, OPT_FONT},
        {"size", required_argument, 0, OPT_SIZE},
        {"color", required_argument, 0, OPT_COLOR},
        {"flash", no_argument, 0, OPT_FLASH},
        {"flash-speed", required_argument, 0, OPT_FLASH_SPEED},
        {"flash-style", required_argument, 0, OPT_FLASH_STYLE},
        {"bg", required_argument, 0, OPT_BG},
        {"bg-color", required_argument, 0, OPT_BG_COLOR},
        {"bg-size", required_argument, 0, OPT_BG_SIZE},
        {"scroll", required_argument, 0, OPT_SCROLL},
        {"scroll-style", required_argument, 0, OPT_SCROLL_STYLE},
        {"sticky", no_argument, 0, OPT_STICKY},
        {"no-sticky", no_argument, 0, OPT_NO_STICKY},
        {"visible-all-desktops", no_argument, 0, OPT_STICKY},
        {"label", required_argument, 0, OPT_LABEL},
        {"on-finish", required_argument, 0, OPT_ON_FINISH},
        {"exit-on-finish", no_argument, 0, OPT_EXIT_ON_FINISH},
        {"on-success", required_argument, 0, OPT_ON_SUCCESS},
        {"alarm", required_argument, 0, OPT_ALARM},
        {"alarm-repeat", required_argument, 0, OPT_ALARM_REPEAT},
        {"animate-when-active", no_argument, 0, OPT_ANIM_ACTIVE},
        {"no-animate-when-active", no_argument, 0, OPT_NO_ANIM_ACTIVE},
        {"animate-when-paused", no_argument, 0, OPT_ANIM_PAUSED},
        {"no-animate-when-paused", no_argument, 0, OPT_NO_ANIM_PAUSED},
        {"focus-follow", no_argument, 0, OPT_FOCUS_FOLLOW},
        {"no-focus-follow", no_argument, 0, OPT_NO_FOCUS_FOLLOW},
        {"animate-all-segments", no_argument, 0, OPT_ANIM_ALL_SEGS},
        {"animate-changed-segment-only", no_argument, 0, OPT_ANIM_CHANGED_SEG},
        {"on-right-click", required_argument, 0, OPT_ON_RC},
        {"on-right-dblclick", required_argument, 0, OPT_ON_RDC},
        {"on-left-click", required_argument, 0, OPT_ON_LC},
        {"on-left-dblclick", required_argument, 0, OPT_ON_LDC},
        {"on-scroll-up", required_argument, 0, OPT_ON_SU},
        {"on-scroll-down", required_argument, 0, OPT_ON_SD},
        {"config", required_argument, 0, 'c'},
        {"help", no_argument, 0, 'h'},
        {"version", no_argument, 0, 'v'},
        {0, 0, 0, 0}
    };

    int c;
    optind = 1;
    while ((c = getopt_long(argc, argv, "t:x:y:c:hv", long_opts, NULL)) != -1) {
        switch (c) {
            case 't': {
                long secs;
                if (!timefmt_parse_duration(optarg, &secs)) {
                    fprintf(stderr, "invalid --time '%s'\n", optarg);
                    return 0;
                }
                cfg->total_seconds = secs;
                break;
            }
            case 'x': cfg->x = atoi(optarg); cfg->has_x = 1; break;
            case 'y': cfg->y = atoi(optarg); cfg->has_y = 1; break;
            case 'c': snprintf(cfg->config_path, sizeof(cfg->config_path), "%s", optarg); break;
            case OPT_FORMAT:
                if (!timefmt_validate(optarg)) {
                    fprintf(stderr, "invalid --format '%s'\n", optarg);
                    return 0;
                }
                snprintf(cfg->format, sizeof(cfg->format), "%s", optarg);
                break;
            case OPT_FONT: snprintf(cfg->font, sizeof(cfg->font), "%s", optarg); break;
            case OPT_SIZE: cfg->font_size = atoi(optarg); break;
            case OPT_COLOR: snprintf(cfg->color, sizeof(cfg->color), "%s", optarg); break;
            case OPT_FLASH: cfg->flash = 1; break;
            case OPT_FLASH_SPEED: cfg->flash_speed = atof(optarg); break;
            case OPT_FLASH_STYLE:
                if (strcasecmp(optarg, "fade") == 0) cfg->flash_style = FLASH_FADE;
                else if (strcasecmp(optarg, "throb") == 0 || strcasecmp(optarg, "beat") == 0) cfg->flash_style = FLASH_THROB;
                else if (strcasecmp(optarg, "blink") == 0) cfg->flash_style = FLASH_BLINK;
                else { fprintf(stderr, "invalid --flash-style '%s'\n", optarg); return 0; }
                break;
            case OPT_BG:
                if (strcasecmp(optarg, "none") == 0) cfg->bg = BG_NONE;
                else if (strcasecmp(optarg, "transparent") == 0) cfg->bg = BG_TRANSPARENT;
                else if (strcasecmp(optarg, "circle") == 0) cfg->bg = BG_CIRCLE;
                else if (strcasecmp(optarg, "square") == 0) cfg->bg = BG_SQUARE;
                else if (strcasecmp(optarg, "shadow") == 0) cfg->bg = BG_SHADOW;
                else { fprintf(stderr, "invalid --bg '%s'\n", optarg); return 0; }
                break;
            case OPT_BG_COLOR: snprintf(cfg->bg_color, sizeof(cfg->bg_color), "%s", optarg); break;
            case OPT_BG_SIZE: cfg->bg_size = strcasecmp(optarg, "auto") == 0 ? 0 : atoi(optarg); break;
            case OPT_SCROLL: cfg->scroll_seconds = atof(optarg); break;
            case OPT_SCROLL_STYLE:
                if (strcasecmp(optarg, "slide") == 0) cfg->scroll_style = SCROLL_SLIDE;
                else if (strcasecmp(optarg, "flip") == 0) cfg->scroll_style = SCROLL_FLIP;
                else if (strcasecmp(optarg, "bounce") == 0) cfg->scroll_style = SCROLL_BOUNCE;
                else { fprintf(stderr, "invalid --scroll-style '%s'\n", optarg); return 0; }
                break;
            case OPT_STICKY: cfg->sticky = 1; break;
            case OPT_NO_STICKY: cfg->sticky = 0; break;
            case OPT_LABEL: snprintf(cfg->label, sizeof(cfg->label), "%s", optarg); break;
            case OPT_ON_FINISH: snprintf(cfg->on_finish_cmd, sizeof(cfg->on_finish_cmd), "%s", optarg); break;
            case OPT_EXIT_ON_FINISH: cfg->exit_on_finish = 1; break;
            case OPT_ON_SUCCESS: snprintf(cfg->on_success_cmd, sizeof(cfg->on_success_cmd), "%s", optarg); break;
            case OPT_ALARM: snprintf(cfg->alarm_path, sizeof(cfg->alarm_path), "%s", optarg); break;
            case OPT_ALARM_REPEAT: cfg->alarm_repeat = atoi(optarg); break;
            case OPT_ANIM_ACTIVE: cfg->animate_when_active = 1; break;
            case OPT_NO_ANIM_ACTIVE: cfg->animate_when_active = 0; break;
            case OPT_ANIM_PAUSED: cfg->animate_when_paused = 1; break;
            case OPT_NO_ANIM_PAUSED: cfg->animate_when_paused = 0; break;
            case OPT_FOCUS_FOLLOW: cfg->focus_follow = 1; break;
            case OPT_NO_FOCUS_FOLLOW: cfg->focus_follow = 0; break;
            case OPT_ANIM_ALL_SEGS: cfg->animate_all_segments = 1; break;
            case OPT_ANIM_CHANGED_SEG: cfg->animate_all_segments = 0; break;
            case OPT_ON_RC:
                if (!config_parse_binding(optarg, &cfg->on_right_click)) { fprintf(stderr, "invalid action '%s'\n", optarg); return 0; }
                break;
            case OPT_ON_RDC:
                if (!config_parse_binding(optarg, &cfg->on_right_dblclick)) { fprintf(stderr, "invalid action '%s'\n", optarg); return 0; }
                break;
            case OPT_ON_LC:
                if (!config_parse_binding(optarg, &cfg->on_left_click)) { fprintf(stderr, "invalid action '%s'\n", optarg); return 0; }
                break;
            case OPT_ON_LDC:
                if (!config_parse_binding(optarg, &cfg->on_left_dblclick)) { fprintf(stderr, "invalid action '%s'\n", optarg); return 0; }
                break;
            case OPT_ON_SU:
                if (!config_parse_binding(optarg, &cfg->on_scroll_up)) { fprintf(stderr, "invalid action '%s'\n", optarg); return 0; }
                break;
            case OPT_ON_SD:
                if (!config_parse_binding(optarg, &cfg->on_scroll_down)) { fprintf(stderr, "invalid action '%s'\n", optarg); return 0; }
                break;
            case 'h': print_usage(argv[0]); exit(0);
            case 'v': printf("countdown %s\n", CD_VERSION); exit(0);
            default: return 0;
        }
    }
    return 1;
}
