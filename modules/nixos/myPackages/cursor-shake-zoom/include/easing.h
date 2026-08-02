#ifndef CURSOR_SCALER_EASING_H
#define CURSOR_SCALER_EASING_H

#include <math.h>
#include "config.h"

/* All curves are cheap (a handful of flops) - safe to call once per frame. */
static inline double ease_apply(EasingType type, double t) {
    if (t < 0.0) t = 0.0;
    if (t > 1.0) t = 1.0;

    switch (type) {
        case EASE_LINEAR:
            return t;

        case EASE_QUAD_IN:
            return t * t;

        case EASE_QUAD_OUT:
            return t * (2.0 - t);

        case EASE_QUAD_IN_OUT:
            return t < 0.5 ? 2.0 * t * t
                           : -1.0 + (4.0 - 2.0 * t) * t;

        case EASE_CUBIC_IN:
            return t * t * t;

        case EASE_CUBIC_OUT: {
            double p = t - 1.0;
            return p * p * p + 1.0;
        }

        case EASE_CUBIC_IN_OUT:
            return t < 0.5
                ? 4.0 * t * t * t
                : (t - 1.0) * (2.0 * t - 2.0) * (2.0 * t - 2.0) + 1.0;

        case EASE_EXPO_OUT:
            return t >= 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);

        case EASE_BACK_OUT: {
            const double c1 = 1.70158;
            const double c3 = c1 + 1.0;
            double p = t - 1.0;
            return 1.0 + c3 * p * p * p + c1 * p * p;
        }

        default:
            return t;
    }
}

#endif /* CURSOR_SCALER_EASING_H */
