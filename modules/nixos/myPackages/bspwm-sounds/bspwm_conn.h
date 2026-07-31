#ifndef BSPWM_CONN_H
#define BSPWM_CONN_H

#include <stddef.h>

#define BSPWM_LINE_MAX 1024

typedef struct {
    int fd;
    char buf[4096];
    size_t buf_len; /* bytes currently buffered (unprocessed) */
} bspwm_conn_t;

/* Connects to bspwm's socket (using $BSPWM_SOCKET or bspwm's own default
 * naming scheme as a fallback) and sends the "subscribe" handshake so the
 * socket starts streaming event report lines. Returns 0 on success. */
int bspwm_connect(bspwm_conn_t *c);

/* Blocks (via the caller's poll/select on c->fd) until at least one full
 * line is available, then returns it with the trailing newline stripped.
 * Returns 1 if a line was produced, 0 on EOF/error. Non-blocking with
 * respect to partial reads: call this after poll() reports c->fd readable. */
int bspwm_read_event(bspwm_conn_t *c, char *out, size_t out_sz);

void bspwm_close(bspwm_conn_t *c);

#endif
