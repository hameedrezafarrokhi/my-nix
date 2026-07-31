#ifndef XWWW_UTIL_H
#define XWWW_UTIL_H

#include <stdint.h>
#include <time.h>

typedef enum {
    EASE_LINEAR = 0,
    EASE_IN_QUAD,
    EASE_OUT_QUAD,
    EASE_INOUT_QUAD,
    EASE_IN_CUBIC,
    EASE_OUT_CUBIC,
    EASE_INOUT_CUBIC,
    EASE_COUNT
} easing_t;

easing_t    easing_from_name(const char *name);
const char *easing_name(easing_t e);
double      easing_apply(easing_t e, double t);

double now_seconds(void);
void   sleep_seconds(double s);

/* Deterministic xorshift RNG, seeded once per process (or by --seed). */
void     xrng_seed(uint64_t seed);
uint64_t xrng_next(void);
double   xrng_double(void);          /* [0,1) */
int      xrng_int(int lo, int hi);   /* inclusive */

#endif
