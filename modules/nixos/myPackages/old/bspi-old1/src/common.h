#ifndef BSPI_COMMON_H
#define BSPI_COMMON_H

#include <stdio.h>
#include <stdarg.h>
#include <time.h>

/* Simple leveled logging to stderr. journald / systemd will happily
 * timestamp these itself, but we add our own so plain terminal use
 * is still readable. */

typedef enum {
    LOG_LVL_ERROR = 0,
    LOG_LVL_WARN  = 1,
    LOG_LVL_INFO  = 2,
    LOG_LVL_DEBUG = 3,
} log_level_t;

extern log_level_t g_log_level;

static inline void bspi_log(log_level_t lvl, const char *fmt, ...) {
    if (lvl > g_log_level) return;

    static const char *names[] = { "ERROR", "WARN", "INFO", "DEBUG" };
    time_t t = time(NULL);
    struct tm tmv;
    localtime_r(&t, &tmv);
    char ts[32];
    strftime(ts, sizeof(ts), "%H:%M:%S", &tmv);

    fprintf(stderr, "[%s] %-5s ", ts, names[lvl]);

    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);

    fprintf(stderr, "\n");
}

#define LOGE(...) bspi_log(LOG_LVL_ERROR, __VA_ARGS__)
#define LOGW(...) bspi_log(LOG_LVL_WARN,  __VA_ARGS__)
#define LOGI(...) bspi_log(LOG_LVL_INFO,  __VA_ARGS__)
#define LOGD(...) bspi_log(LOG_LVL_DEBUG, __VA_ARGS__)

#endif /* BSPI_COMMON_H */
