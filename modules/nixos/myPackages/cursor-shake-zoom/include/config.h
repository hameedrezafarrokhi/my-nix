#ifndef CURSOR_SCALER_CONFIG_H
#define CURSOR_SCALER_CONFIG_H

#include <stddef.h>

/* Available easing curves for the zoom animation. */
typedef enum {
    EASE_LINEAR = 0,
    EASE_QUAD_IN,
    EASE_QUAD_OUT,
    EASE_QUAD_IN_OUT,
    EASE_CUBIC_IN,
    EASE_CUBIC_OUT,
    EASE_CUBIC_IN_OUT,
    EASE_EXPO_OUT,
    EASE_BACK_OUT,
} EasingType;

/* How to handle the "no compositor" case. */
typedef enum {
    SHAPE_AUTO = 0,   /* detect compositor presence at startup */
    SHAPE_FORCE_ON,   /* always cut the window with XShape          */
    SHAPE_FORCE_OFF,  /* never cut the window (assume ARGB blending) */
} ShapeMode;

typedef struct {
    /* shake detection */
    int    shake_threshold;      /* direction reversals needed to trigger a zoom */
    double shake_timeout;        /* seconds of no reversal before the streak resets */
    double movement_threshold;   /* px of motion needed to register a direction */

    /* scaling */
    double min_scale;
    double max_scale;
    double zoom_in_rate;         /* scale units per second while actively shaking (always linear) */

    /* animation */
    double     zoom_out_duration; /* seconds for the single shrink-back-to-normal transition */
    EasingType easing;            /* only applied to the shrink-back transition */
    int        fps;               /* animation frame cap while actively zooming */

    /* fullscreen guard */
    int disable_in_fullscreen;    /* don't engage while the focused window is fullscreen (games) */

    /* cursor source */
    char cursor_name[128];       /* xcursor name, e.g. "left_ptr" */
    char cursor_theme[128];      /* empty = use XCURSOR_THEME / default theme */
    int  cursor_size;            /* 0 = auto (largest available in theme) */

    /* lossless (SVG) scaling */
    char svg_path[512];          /* explicit path to a source SVG, empty = auto/off */
    int  disable_svg;            /* force-disable svg even if available */

    /* rendering */
    char      filter[32];        /* xrender filter: "best", "good", "bilinear", "nearest" */
    ShapeMode shape_mode;

    char config_path[512];       /* resolved path of the config file that was loaded, if any */
} Config;

void config_set_defaults(Config *cfg);
int  config_load_file(Config *cfg, const char *path);
int  config_parse_args(Config *cfg, int argc, char **argv); /* returns 0=continue, 1=exit(success), -1=exit(error) */
void config_print(const Config *cfg);
void config_default_path(char *buf, size_t buflen);

EasingType  easing_from_string(const char *s);
const char *easing_to_string(EasingType e);

#endif /* CURSOR_SCALER_CONFIG_H */
