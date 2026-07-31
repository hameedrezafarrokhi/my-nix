#ifndef BSPI_IPC_H
#define BSPI_IPC_H

#include <stddef.h>

/*
 * Talks directly to bspwm's Unix domain socket, the same protocol
 * `bspc` itself uses (see bspwm's src/bspc.c / src/message.c):
 *
 *   - Each argument is written NUL-separated (including a trailing
 *     NUL after the last one).
 *   - The reply is read until the peer closes the connection or a
 *     single subscribe-report line arrives.
 *   - If the very first byte of the reply is 0x07, the command failed
 *     and the rest of the buffer is a human-readable error message.
 *
 * This lets bspi avoid forking a `bspc` child process for every single
 * query and rename, which was the single biggest source of overhead in
 * the original script.
 */

/* Resolves the socket path: BSPWM_SOCKET env var if set, otherwise an
 * explicit override (may be NULL), otherwise a best-effort fallback
 * built the same way bspwm itself does when the env var is absent.
 * Returns 0 on success, -1 if nothing could be determined. */
int bspwm_resolve_socket_path(const char *override, char *out, size_t out_len);

/* Sends one command and blocks until the full reply is read.
 * `argv`/`argc` are the bspc-style arguments, e.g. {"wm","-d"} or
 * {"desktop","1234","--rename","foo"}.
 *
 * On success returns 0 and *out_data is a malloc'd NUL-terminated
 * buffer the caller must free(); *out_len is its length excluding the
 * NUL. On failure (connection error OR bspwm reporting a failure)
 * returns -1 and errbuf gets a short reason. */
int bspwm_send(const char *sock_path, const char *const *argv, int argc,
               char **out_data, size_t *out_len,
               char *errbuf, size_t errbuf_len);

/* Opens a persistent subscribe connection for the given report fields
 * (e.g. {"node_add","node_remove","node_transfer"}) and returns the
 * raw fd on success, ready to be poll()'d. Each readable line on this
 * fd signals "something changed" - bspi doesn't need to parse the
 * report content, just treat its arrival as a trigger to rescan.
 * Returns -1 on failure. */
int bspwm_subscribe_open(const char *sock_path, const char *const *fields, int nfields,
                          char *errbuf, size_t errbuf_len);

#endif /* BSPI_IPC_H */
