#include "bspwm_conn.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/un.h>

/* The set of report events we actually care about. Kept explicit (rather
 * than relying on bspwm's "all" alias) so behavior doesn't shift under us
 * if bspwm adds new event types later. */
static const char *SUBSCRIBE_FIELDS[] = {
    "subscribe",
    "node_add", "node_remove", "node_swap", "node_transfer",
    "node_focus", "node_activate",
    "desktop_focus", "desktop_add", "desktop_remove",
    "monitor_focus",
    NULL
};

static void derive_default_socket_path(char *out, size_t out_sz) {
    const char *display = getenv("DISPLAY");
    if (!display || !*display) display = ":0";

    char host[128] = "";
    char dnum[32] = "0";
    char snum[32] = "0";

    const char *colon = strrchr(display, ':');
    if (colon) {
        size_t hlen = (size_t)(colon - display);
        if (hlen >= sizeof(host)) hlen = sizeof(host) - 1;
        memcpy(host, display, hlen);
        host[hlen] = '\0';

        const char *rest = colon + 1;
        const char *dot = strchr(rest, '.');
        if (dot) {
            size_t dlen = (size_t)(dot - rest);
            if (dlen >= sizeof(dnum)) dlen = sizeof(dnum) - 1;
            memcpy(dnum, rest, dlen);
            dnum[dlen] = '\0';
            snprintf(snum, sizeof(snum), "%s", dot + 1);
        } else {
            snprintf(dnum, sizeof(dnum), "%s", rest);
        }
    }

    snprintf(out, out_sz, "/tmp/bspwm%s_%s_%s-socket", host, dnum, snum);
}

int bspwm_connect(bspwm_conn_t *c) {
    memset(c, 0, sizeof(*c));

    char socket_path[256];
    const char *env_path = getenv("BSPWM_SOCKET");
    if (env_path && *env_path) {
        snprintf(socket_path, sizeof(socket_path), "%s", env_path);
    } else {
        derive_default_socket_path(socket_path, sizeof(socket_path));
    }

    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) {
        fprintf(stderr, "bspwm-sounds: socket(): %m\n");
        return -1;
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    snprintf(addr.sun_path, sizeof(addr.sun_path), "%s", socket_path);

    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        fprintf(stderr, "bspwm-sounds: connect('%s'): %m\n", socket_path);
        close(fd);
        return -1;
    }

    /* Build the subscribe handshake: each token NUL-separated. */
    char msg[512];
    size_t off = 0;
    for (int i = 0; SUBSCRIBE_FIELDS[i]; i++) {
        size_t len = strlen(SUBSCRIBE_FIELDS[i]) + 1; /* include NUL */
        if (off + len > sizeof(msg)) break;
        memcpy(msg + off, SUBSCRIBE_FIELDS[i], len);
        off += len;
    }

    if (send(fd, msg, off, 0) != (ssize_t)off) {
        fprintf(stderr, "bspwm-sounds: failed to send subscribe handshake: %m\n");
        close(fd);
        return -1;
    }

    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);

    c->fd = fd;
    c->buf_len = 0;
    return 0;
}

int bspwm_read_event(bspwm_conn_t *c, char *out, size_t out_sz) {
    char *nl = memchr(c->buf, '\n', c->buf_len);
    if (nl) {
        size_t line_len = (size_t)(nl - c->buf);
        size_t copy_len = line_len < out_sz - 1 ? line_len : out_sz - 1;
        memcpy(out, c->buf, copy_len);
        out[copy_len] = '\0';
        size_t consumed = line_len + 1;
        memmove(c->buf, c->buf + consumed, c->buf_len - consumed);
        c->buf_len -= consumed;
        return 1;
    }

    if (c->buf_len >= sizeof(c->buf)) {
        /* Pathological: a single "line" longer than our buffer. Drop it. */
        c->buf_len = 0;
        return -1;
    }

    ssize_t n = read(c->fd, c->buf + c->buf_len, sizeof(c->buf) - c->buf_len);
    if (n < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) return 0;
        return -1;
    }
    if (n == 0) return -1; /* EOF: bspwm went away */
    c->buf_len += (size_t)n;

    nl = memchr(c->buf, '\n', c->buf_len);
    if (!nl) return 0;

    size_t line_len = (size_t)(nl - c->buf);
    size_t copy_len = line_len < out_sz - 1 ? line_len : out_sz - 1;
    memcpy(out, c->buf, copy_len);
    out[copy_len] = '\0';
    size_t consumed = line_len + 1;
    memmove(c->buf, c->buf + consumed, c->buf_len - consumed);
    c->buf_len -= consumed;
    return 1;
}

void bspwm_close(bspwm_conn_t *c) {
    if (c->fd >= 0) close(c->fd);
    c->fd = -1;
}
