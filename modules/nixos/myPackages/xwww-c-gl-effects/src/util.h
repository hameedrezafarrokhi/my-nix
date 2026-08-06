#ifndef XWWW_UTIL_H
#define XWWW_UTIL_H

#include <stdint.h>
#include <time.h>

typedef enum {
    EASE_LINEAR = 0,
    EASE_IN_QUAD,       EASE_OUT_QUAD,       EASE_INOUT_QUAD,
    EASE_IN_CUBIC,      EASE_OUT_CUBIC,      EASE_INOUT_CUBIC,
    EASE_IN_SINE,       EASE_OUT_SINE,       EASE_INOUT_SINE,
    EASE_IN_EXPO,       EASE_OUT_EXPO,       EASE_INOUT_EXPO,
    EASE_IN_BACK,       EASE_OUT_BACK,       EASE_INOUT_BACK,
    EASE_IN_ELASTIC,    EASE_OUT_ELASTIC,
    EASE_IN_BOUNCE,     EASE_OUT_BOUNCE,     EASE_INOUT_BOUNCE,
    EASE_CUSTOM_BEZIER, /* see easing_bezier() -- needs 4 extra params, not driven by t alone */
    EASE_COUNT
} easing_t;

easing_t    easing_from_name(const char *name);
const char *easing_name(easing_t e);
double      easing_apply(easing_t e, double t);

/* CSS-style cubic-bezier(x1,y1,x2,y2) timing function: control points
 * (0,0),(x1,y1),(x2,y2),(1,1). Solves x(u)=t for u via Newton-Raphson
 * (falls back to bisection if it doesn't converge) then returns y(u). */
double easing_bezier(double x1, double y1, double x2, double y2, double t);

double now_seconds(void);
void   sleep_seconds(double s);

/* Deterministic xorshift RNG, seeded once per process (or by --seed). */
void     xrng_seed(uint64_t seed);
uint64_t xrng_next(void);
double   xrng_double(void);          /* [0,1) */
int      xrng_int(int lo, int hi);   /* inclusive */

#endif
