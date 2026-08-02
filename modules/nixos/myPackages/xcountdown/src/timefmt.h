#ifndef COUNTDOWN_TIMEFMT_H
#define COUNTDOWN_TIMEFMT_H

#define TIMEFMT_MAX_SEGMENTS 4
#define TIMEFMT_SEG_SIZE 24

/* Parses strings like "90", "90s", "5m", "1h30m", "1h30m15s", "2h", "1d2h"
 * into total seconds. Returns 1 on success, 0 on parse error. */
int timefmt_parse_duration(const char *str, long *out_seconds);

/* Renders `seconds` remaining into `buf` (size bufsz) according to `fmt`.
 * fmt is a colon-separated list of unit letters, largest-to-smallest, e.g.
 * "h:m:s", "m:s", "d:h:m:s", or a single bare unit: "s" or "m" or "h".
 * Also accepts the friendly aliases: "seconds", "minutes", "hours",
 * "hh:mm:ss" (default), "mm:ss", "dd:hh:mm:ss", "hh:mm".
 * All non-leading fields are zero-padded to 2 digits. */
void timefmt_render(const char *fmt, long seconds, char *buf, int bufsz);

/* Same breakdown as timefmt_render, but returns each unit as its own
 * formatted segment (segs[0] largest/unpadded, the rest zero-padded to 2
 * digits) instead of one joined string -- lets the caller animate/lay out
 * each field (e.g. seconds) independently from the others (e.g. h/m).
 * Returns the number of segments filled (<= max_segs). */
int timefmt_render_segments(const char *fmt, long seconds, char segs[][TIMEFMT_SEG_SIZE], int max_segs);

/* Normalizes a friendly alias (e.g. "hh:mm:ss") into the canonical letter
 * form (e.g. "h:m:s") used internally. Returns 1 if fmt was recognized/valid. */
int timefmt_validate(const char *fmt);

#endif
