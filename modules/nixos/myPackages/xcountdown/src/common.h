#ifndef COUNTDOWN_COMMON_H
#define COUNTDOWN_COMMON_H

#include <stdint.h>
#include <time.h>

#define CD_VERSION "1.0.0"

/* ---- background styles ---- */
typedef enum {
    BG_NONE = 0,
    BG_TRANSPARENT,
    BG_CIRCLE,
    BG_SQUARE,
    BG_SHADOW
} bg_style_t;

/* ---- click / scroll actions ---- */
typedef enum {
    ACT_NONE = 0,
    ACT_EXIT,       /* right click: bail out, exit(1) */
    ACT_RESET,      /* double right click: reset to original time */
    ACT_PAUSE,      /* left click: toggle pause/resume */
    ACT_SURPRISE,   /* double left click: fun easter egg */
    ACT_DRAG,       /* left click + hold: move window (fixed, not remappable) */
    ACT_INC,        /* scroll up (default): add seconds */
    ACT_DEC         /* scroll down (default): subtract seconds */
} action_t;

typedef struct {
    action_t action;
    int amount;     /* used by ACT_INC / ACT_DEC, seconds */
} binding_t;

typedef enum {
    SCROLL_SLIDE = 0,   /* old text slides/fades up and out, new slides in */
    SCROLL_FLIP,        /* split-flap / mechanical-clock style flip */
    SCROLL_BOUNCE        /* like slide, but with a springy overshoot ease */
} scroll_style_t;

typedef enum {
    FLASH_FADE = 0,     /* smooth continuous pulse, 0..1..0 */
    FLASH_THROB,        /* heartbeat-style double "thump-thump ... " beat */
    FLASH_BLINK         /* hard on/off blink */
} flash_style_t;

/* ---- full app configuration (config file + CLI overrides) ---- */
typedef struct {
    /* timing */
    long total_seconds;        /* initial duration, from -t/--time */
    char format[64];           /* e.g. "hh:mm:ss", "mm:ss", "seconds" ... */

    /* geometry */
    int x, y;                  /* -1 == "not set", centered fallback handled by caller */
    int has_x, has_y;

    /* appearance */
    char font[128];
    int font_size;
    char color[16];             /* "#rrggbb" or "#rrggbbaa" */

    int flash;                  /* bool: enable fade in/out */
    double flash_speed;         /* 1..10, 5 = neutral midpoint */
    flash_style_t flash_style;  /* fade (default), throb, blink */

    int animate_when_active;    /* run flash/transition animation while counting down (default on) */
    int animate_when_paused;    /* run flash/transition animation while paused (default off) */

    /* When true (default), continuous flash/throb/blink pulses every
     * segment (h/m/s) together, same as animating one joined string.
     * When false, only the fastest-changing segment (rightmost, e.g.
     * seconds) pulses continuously; slower segments (minutes, hours) sit
     * still. Digit-change transitions (--scroll/--scroll-style) always
     * only animate whichever segment(s) actually changed, regardless of
     * this setting -- it only affects the continuous flash pulse. */
    int animate_all_segments;

    int focus_follow;           /* take/release input focus on mouse enter/leave (default on) */

    bg_style_t bg;
    char bg_color[16];
    int bg_size;                 /* pixels; 0 == auto (fit to text + padding) */

    double scroll_seconds;       /* digit "odometer" transition duration, 0 = instant */
    scroll_style_t scroll_style; /* slide (default), flip, or bounce */

    int sticky;                  /* visible on all desktops */

    char label[128];             /* optional caption text */
    char on_finish_cmd[512];     /* shell command run once when timer hits 0 */

    int exit_on_finish;          /* if set, quit (exit code 0) once the timer
                                   * hits 0 and any alarm has finished playing.
                                   * default off: widget just stays at 0. */
    char on_success_cmd[512];    /* shell command run only when the process
                                   * is about to exit with code 0 (never on
                                   * the right-click "cancel" exit-1 path) */

    char alarm_path[512];        /* sound file to play when the timer hits 0 */
    int alarm_repeat;            /* how many times to play it; 0 = repeat
                                   * indefinitely until the user moves the
                                   * mouse over the widget or presses a key */

    /* click / scroll bindings */
    binding_t on_right_click;
    binding_t on_right_dblclick;
    binding_t on_left_click;
    binding_t on_left_dblclick;
    binding_t on_scroll_up;
    binding_t on_scroll_down;

    char config_path[512];
} config_t;

void config_set_defaults(config_t *cfg);

#endif
