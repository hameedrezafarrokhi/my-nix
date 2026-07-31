#include "util.h"
#include <string.h>
#include <strings.h>
#include <math.h>
#include <unistd.h>
#include <stdlib.h>

static const char *EASE_NAMES[EASE_COUNT] = {
    "linear", "ease-in-quad", "ease-out-quad", "ease-in-out-quad",
    "ease-in-cubic", "ease-out-cubic", "ease-in-out-cubic"
};

easing_t easing_from_name(const char *name) {
    if (!name || !*name) return EASE_LINEAR;
    for (int i = 0; i < EASE_COUNT; i++)
        if (strcasecmp(name, EASE_NAMES[i]) == 0) return (easing_t)i;
    return EASE_LINEAR;
}

const char *easing_name(easing_t e) {
    if (e < 0 || e >= EASE_COUNT) return "linear";
    return EASE_NAMES[e];
}

double easing_apply(easing_t e, double t) {
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    switch (e) {
        case EASE_IN_QUAD:      return t * t;
        case EASE_OUT_QUAD:     return t * (2 - t);
        case EASE_INOUT_QUAD:   return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
        case EASE_IN_CUBIC:     return t * t * t;
        case EASE_OUT_CUBIC: {
            double u = t - 1;
            return u * u * u + 1;
        }
        case EASE_INOUT_CUBIC:
            return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
        case EASE_LINEAR:
        default:                return t;
    }
}

double now_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + ts.tv_nsec / 1e9;
}

void sleep_seconds(double s) {
    if (s <= 0) return;
    struct timespec ts;
    ts.tv_sec = (time_t)s;
    ts.tv_nsec = (long)((s - ts.tv_sec) * 1e9);
    nanosleep(&ts, NULL);
}

static uint64_t rng_state = 0x9E3779B97F4A7C15ULL;

void xrng_seed(uint64_t seed) {
    rng_state = seed ? seed : 0x9E3779B97F4A7C15ULL;
}

uint64_t xrng_next(void) {
    /* xorshift64* */
    uint64_t x = rng_state;
    x ^= x >> 12;
    x ^= x << 25;
    x ^= x >> 27;
    rng_state = x;
    return x * 0x2545F4914F6CDD1DULL;
}

double xrng_double(void) {
    return (double)(xrng_next() >> 11) * (1.0 / 9007199254740992.0);
}

int xrng_int(int lo, int hi) {
    if (hi <= lo) return lo;
    return lo + (int)(xrng_next() % (uint64_t)(hi - lo + 1));
}
