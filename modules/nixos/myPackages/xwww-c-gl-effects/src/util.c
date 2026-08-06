#include "util.h"
#include <string.h>
#include <strings.h>
#include <math.h>
#include <unistd.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

static const char *EASE_NAMES[EASE_COUNT] = {
    "linear",
    "ease-in-quad", "ease-out-quad", "ease-in-out-quad",
    "ease-in-cubic", "ease-out-cubic", "ease-in-out-cubic",
    "ease-in-sine", "ease-out-sine", "ease-in-out-sine",
    "ease-in-expo", "ease-out-expo", "ease-in-out-expo",
    "ease-in-back", "ease-out-back", "ease-in-out-back",
    "ease-in-elastic", "ease-out-elastic",
    "ease-in-bounce", "ease-out-bounce", "ease-in-out-bounce",
    "bezier",
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

static double bounce_out(double t) {
    const double n1 = 7.5625, d1 = 2.75;
    if (t < 1 / d1) return n1 * t * t;
    if (t < 2 / d1) { t -= 1.5 / d1; return n1 * t * t + 0.75; }
    if (t < 2.5 / d1) { t -= 2.25 / d1; return n1 * t * t + 0.9375; }
    t -= 2.625 / d1; return n1 * t * t + 0.984375;
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

        case EASE_IN_SINE:    return 1 - cos(t * M_PI / 2);
        case EASE_OUT_SINE:   return sin(t * M_PI / 2);
        case EASE_INOUT_SINE: return -(cos(M_PI * t) - 1) / 2;

        case EASE_IN_EXPO:    return t <= 0 ? 0 : pow(2, 10 * t - 10);
        case EASE_OUT_EXPO:   return t >= 1 ? 1 : 1 - pow(2, -10 * t);
        case EASE_INOUT_EXPO:
            if (t <= 0) return 0;
            if (t >= 1) return 1;
            return t < 0.5 ? pow(2, 20 * t - 10) / 2 : (2 - pow(2, -20 * t + 10)) / 2;

        case EASE_IN_BACK: {
            const double c1 = 1.70158, c3 = c1 + 1;
            return c3 * t * t * t - c1 * t * t;
        }
        case EASE_OUT_BACK: {
            const double c1 = 1.70158, c3 = c1 + 1;
            double u = t - 1;
            return 1 + c3 * u * u * u + c1 * u * u;
        }
        case EASE_INOUT_BACK: {
            const double c1 = 1.70158, c2 = c1 * 1.525;
            if (t < 0.5) {
                double u = 2 * t;
                return (u * u * ((c2 + 1) * u - c2)) / 2;
            } else {
                double u = 2 * t - 2;
                return (u * u * ((c2 + 1) * u + c2) + 2) / 2;
            }
        }

        case EASE_IN_ELASTIC: {
            const double c4 = (2 * M_PI) / 3;
            if (t <= 0) return 0;
            if (t >= 1) return 1;
            return -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * c4);
        }
        case EASE_OUT_ELASTIC: {
            const double c4 = (2 * M_PI) / 3;
            if (t <= 0) return 0;
            if (t >= 1) return 1;
            return pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1;
        }

        case EASE_IN_BOUNCE:  return 1 - bounce_out(1 - t);
        case EASE_OUT_BOUNCE: return bounce_out(t);
        case EASE_INOUT_BOUNCE:
            return t < 0.5 ? (1 - bounce_out(1 - 2 * t)) / 2 : (1 + bounce_out(2 * t - 1)) / 2;

        case EASE_LINEAR:
        case EASE_CUSTOM_BEZIER: /* caller should use easing_bezier() directly for this one */
        default:
            return t;
    }
}

double easing_bezier(double x1, double y1, double x2, double y2, double t) {
    /* Solve x(u) = t for u in [0,1] via Newton-Raphson, falling back to
     * bisection if the derivative gets too flat to converge cleanly
     * (matches the standard approach browsers use for CSS cubic-bezier). */
    if (t <= 0) return 0;
    if (t >= 1) return 1;

    double u = t; /* good initial guess */
    for (int i = 0; i < 8; i++) {
        double mu = 1 - u;
        double x = 3 * mu * mu * u * x1 + 3 * mu * u * u * x2 + u * u * u;
        double dx = 3 * mu * mu * x1 + 6 * mu * u * (x2 - x1) + 3 * u * u * (1 - x2);
        if (fabs(dx) < 1e-6) break;
        double u2 = u - (x - t) / dx;
        if (u2 < 0 || u2 > 1) break;
        u = u2;
        if (fabs(x - t) < 1e-6) break;
    }
    if (u < 0 || u > 1) { /* Newton diverged: bisection fallback */
        double lo = 0, hi = 1;
        u = t;
        for (int i = 0; i < 30; i++) {
            double mu = 1 - u;
            double x = 3 * mu * mu * u * x1 + 3 * mu * u * u * x2 + u * u * u;
            if (x < t) lo = u; else hi = u;
            u = (lo + hi) / 2;
        }
    }
    double mu = 1 - u;
    return 3 * mu * mu * u * y1 + 3 * mu * u * u * y2 + u * u * u;
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
