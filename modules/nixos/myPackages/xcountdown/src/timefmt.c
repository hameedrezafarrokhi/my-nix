#define _POSIX_C_SOURCE 200809L
#include "timefmt.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>

int timefmt_parse_duration(const char *str, long *out_seconds) {
    if (!str || !*str) return 0;

    /* Pure integer (e.g. "90", "3600") means seconds, matching common CLI
     * conventions like `sleep`, but we also allow suffixed compound forms
     * like "1h30m15s" or "2d". */
    int all_digits = 1;
    for (const char *p = str; *p; p++) {
        if (!isdigit((unsigned char)*p)) { all_digits = 0; break; }
    }
    if (all_digits) {
        long v = strtol(str, NULL, 10);
        if (v < 0) return 0;
        *out_seconds = v;
        return 1;
    }

    long total = 0;
    const char *p = str;
    int matched_any = 0;
    while (*p) {
        while (*p == ' ') p++;
        if (!*p) break;
        if (!isdigit((unsigned char)*p)) return 0;
        char *end;
        long val = strtol(p, &end, 10);
        if (end == p) return 0;
        p = end;
        if (!*p) return 0; /* trailing number with no unit */
        char unit = tolower((unsigned char)*p);
        long mult;
        switch (unit) {
            case 'd': mult = 86400; break;
            case 'h': mult = 3600; break;
            case 'm': mult = 60; break;
            case 's': mult = 1; break;
            default: return 0;
        }
        total += val * mult;
        matched_any = 1;
        p++;
    }
    if (!matched_any) return 0;
    *out_seconds = total;
    return 1;
}

/* Translate friendly aliases to canonical colon-separated unit-letter form.
 * Returns 1 and fills `out` (>=16 bytes) on success. */
static int normalize_format(const char *fmt, char *out, int outsz) {
    struct { const char *alias; const char *canon; } table[] = {
        {"seconds", "s"}, {"minutes", "m"}, {"hours", "h"}, {"days", "d"},
        {"ss", "s"}, {"mm", "m"}, {"hh", "h"}, {"dd", "d"},
        {"hh:mm:ss", "h:m:s"}, {"mm:ss", "m:s"}, {"hh:mm", "h:m"},
        {"dd:hh:mm:ss", "d:h:m:s"}, {"dd:hh:mm", "d:h:m"}, {"dd:hh", "d:h"},
    };
    for (size_t i = 0; i < sizeof(table)/sizeof(table[0]); i++) {
        if (strcasecmp(fmt, table[i].alias) == 0) {
            snprintf(out, outsz, "%s", table[i].canon);
            return 1;
        }
    }
    /* Otherwise, require it to already be a valid colon-separated list of
     * d/h/m/s letters (case-insensitive), e.g. "h:m:s" or "s". */
    char tmp[64];
    snprintf(tmp, sizeof(tmp), "%s", fmt);
    for (char *c = tmp; *c; c++) *c = (char)tolower((unsigned char)*c);
    const char *valid_units = "dhms";
    char *tok = strtok(tmp, ":");
    int count = 0;
    char rebuilt[64] = {0};
    while (tok) {
        if (strlen(tok) != 1 || !strchr(valid_units, tok[0])) return 0;
        if (count > 0) strncat(rebuilt, ":", sizeof(rebuilt) - strlen(rebuilt) - 1);
        strncat(rebuilt, tok, sizeof(rebuilt) - strlen(rebuilt) - 1);
        count++;
        tok = strtok(NULL, ":");
    }
    if (count == 0) return 0;
    snprintf(out, outsz, "%s", rebuilt);
    return 1;
}

int timefmt_validate(const char *fmt) {
    char out[64];
    return normalize_format(fmt, out, sizeof(out));
}

/* Shared by timefmt_render and timefmt_render_segments: figures out which
 * units (d/h/m/s, largest first) `fmt` calls for and their integer values,
 * with the largest shown unit absorbing everything above it (so format
 * "m:s" on 3700s means total minutes: 61:40, not minutes-of-hour). */
static int compute_units_values(const char *fmt, long seconds, char units[4], long values[4]) {
    if (seconds < 0) seconds = 0;
    char canon[64];
    if (!normalize_format(fmt, canon, sizeof(canon))) {
        snprintf(canon, sizeof(canon), "h:m:s"); /* safe fallback */
    }

    long d = seconds / 86400;
    long h = (seconds % 86400) / 3600;
    long m = (seconds % 3600) / 60;
    long s = seconds % 60;

    int nunits = 0;
    char tmp[64];
    snprintf(tmp, sizeof(tmp), "%s", canon);
    char *tok = strtok(tmp, ":");
    while (tok && nunits < 4) {
        units[nunits++] = tok[0];
        tok = strtok(NULL, ":");
    }

    long total_s = seconds;
    for (int i = 0; i < nunits; i++) {
        int is_largest = (i == 0);
        long v = 0;
        switch (units[i]) {
            case 'd': v = is_largest ? total_s / 86400 : d; break;
            case 'h': v = is_largest ? total_s / 3600 : h; break;
            case 'm': v = is_largest ? total_s / 60 : m; break;
            case 's': v = is_largest ? total_s : s; break;
        }
        values[i] = v;
    }
    return nunits;
}

void timefmt_render(const char *fmt, long seconds, char *buf, int bufsz) {
    char units[4];
    long values[4];
    int nunits = compute_units_values(fmt, seconds, units, values);

    buf[0] = '\0';
    int off = 0;
    for (int i = 0; i < nunits; i++) {
        int n;
        if (i == 0) n = snprintf(buf + off, bufsz - off, "%ld", values[i]);
        else n = snprintf(buf + off, bufsz - off, ":%02ld", values[i]);
        if (n < 0 || off + n >= bufsz) break;
        off += n;
    }
}

int timefmt_render_segments(const char *fmt, long seconds, char segs[][TIMEFMT_SEG_SIZE], int max_segs) {
    char units[4];
    long values[4];
    int nunits = compute_units_values(fmt, seconds, units, values);
    if (nunits > max_segs) nunits = max_segs;

    for (int i = 0; i < nunits; i++) {
        if (i == 0) snprintf(segs[i], TIMEFMT_SEG_SIZE, "%ld", values[i]);
        else snprintf(segs[i], TIMEFMT_SEG_SIZE, "%02ld", values[i]);
    }
    return nunits;
}
