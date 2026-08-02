#include "ipc.h"
#include "common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <xcb/xcb.h>

#define FAILURE_BYTE 0x07

static int connect_unix(const char *path, char *errbuf, size_t errbuf_len) {
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) {
        if (errbuf) snprintf(errbuf, errbuf_len, "socket(): %s", strerror(errno));
        return -1;
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    if (strlen(path) >= sizeof(addr.sun_path)) {
        if (errbuf) snprintf(errbuf, errbuf_len, "socket path too long");
        close(fd);
        return -1;
    }
    strncpy(addr.sun_path, path, sizeof(addr.sun_path) - 1);

    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        if (errbuf) snprintf(errbuf, errbuf_len, "connect('%s'): %s", path, strerror(errno));
        close(fd);
        return -1;
    }
    return fd;
}

int bspwm_resolve_socket_path(const char *override, char *out, size_t out_len) {
    if (override && *override) {
        snprintf(out, out_len, "%s", override);
        return 0;
    }

    const char *env = getenv("BSPWM_SOCKET");
    if (env && *env) {
        snprintf(out, out_len, "%s", env);
        return 0;
    }

    /* Best-effort fallback, mirroring bspwm's own default when the env
     * var isn't set: /tmp/bspwm<host>_<display>_<screen>-socket. This
     * only matters if bspi is started somewhere that didn't inherit
     * BSPWM_SOCKET from the bspwm session (e.g. a systemd unit without
     * the environment imported) - callers are encouraged to pass
     * --socket explicitly in that case instead of relying on this. */
    char *host = NULL;
    int display = 0, screen = 0;
    if (xcb_parse_display(NULL, &host, &display, &screen) == 0) {
        free(host);
        return -1;
    }
    snprintf(out, out_len, "/tmp/bspwm%s_%d_%d-socket", host ? host : "", display, screen);
    free(host);
    LOGW("BSPWM_SOCKET is not set; guessing socket path '%s' - if this is "
         "wrong, pass --socket explicitly", out);
    return 0;
}

static int send_all(int fd, const char *buf, size_t len) {
    size_t sent = 0;
    while (sent < len) {
        ssize_t n = send(fd, buf + sent, len - sent, MSG_NOSIGNAL);
        if (n < 0) {
            if (errno == EINTR) continue;
            return -1;
        }
        sent += (size_t)n;
    }
    return 0;
}

int bspwm_send(const char *sock_path, const char *const *argv, int argc,
               char **out_data, size_t *out_len,
               char *errbuf, size_t errbuf_len) {
    *out_data = NULL;
    *out_len = 0;

    /* Build the NUL-separated message. */
    size_t cap = 4096;
    char *msg = malloc(cap);
    if (!msg) { if (errbuf) snprintf(errbuf, errbuf_len, "out of memory"); return -1; }
    size_t off = 0;
    for (int i = 0; i < argc; i++) {
        size_t alen = strlen(argv[i]) + 1; /* + NUL */
        if (off + alen > cap) {
            cap = (off + alen) * 2;
            char *nm = realloc(msg, cap);
            if (!nm) { free(msg); if (errbuf) snprintf(errbuf, errbuf_len, "out of memory"); return -1; }
            msg = nm;
        }
        memcpy(msg + off, argv[i], alen - 1);
        msg[off + alen - 1] = '\0';
        off += alen;
    }

    if (off == 0) {
        free(msg);
        if (errbuf) snprintf(errbuf, errbuf_len, "no arguments given");
        return -1;
    }

    int fd = connect_unix(sock_path, errbuf, errbuf_len);
    if (fd < 0) { free(msg); return -1; }

    int rc = send_all(fd, msg, off);
    free(msg);
    if (rc != 0) {
        if (errbuf) snprintf(errbuf, errbuf_len, "send(): %s", strerror(errno));
        close(fd);
        return -1;
    }

    /* Read the reply until the server closes the connection - bspwm
     * writes the whole response and then closes for one-shot
     * commands, which may arrive in several chunks for a large `wm
     * -d` dump. */
    size_t bufcap = 65536;
    size_t buflen = 0;
    char *buf = malloc(bufcap);
    if (!buf) { close(fd); if (errbuf) snprintf(errbuf, errbuf_len, "out of memory"); return -1; }

    for (;;) {
        if (buflen + 4096 > bufcap) {
            bufcap *= 2;
            char *nb = realloc(buf, bufcap);
            if (!nb) { free(buf); close(fd); if (errbuf) snprintf(errbuf, errbuf_len, "out of memory"); return -1; }
            buf = nb;
        }
        ssize_t n = recv(fd, buf + buflen, bufcap - buflen - 1, 0);
        if (n < 0) {
            if (errno == EINTR) continue;
            free(buf);
            close(fd);
            if (errbuf) snprintf(errbuf, errbuf_len, "recv(): %s", strerror(errno));
            return -1;
        }
        if (n == 0) break; /* server closed - done */
        buflen += (size_t)n;
    }
    close(fd);
    buf[buflen] = '\0';

    if (buflen > 0 && (unsigned char)buf[0] == FAILURE_BYTE) {
        if (errbuf) snprintf(errbuf, errbuf_len, "%s", buf + 1);
        free(buf);
        return -1;
    }

    *out_data = buf;
    *out_len = buflen;
    return 0;
}

int bspwm_subscribe_open(const char *sock_path, const char *const *fields, int nfields,
                          char *errbuf, size_t errbuf_len) {
    int fd = connect_unix(sock_path, errbuf, errbuf_len);
    if (fd < 0) return -1;

    size_t cap = 4096;
    char *msg = malloc(cap);
    if (!msg) { close(fd); if (errbuf) snprintf(errbuf, errbuf_len, "out of memory"); return -1; }

    size_t off = 0;
    const char *cmd = "subscribe";
    size_t clen = strlen(cmd) + 1;
    memcpy(msg + off, cmd, clen - 1);
    msg[off + clen - 1] = '\0';
    off += clen;

    for (int i = 0; i < nfields; i++) {
        size_t alen = strlen(fields[i]) + 1;
        if (off + alen > cap) {
            cap = (off + alen) * 2;
            char *nm = realloc(msg, cap);
            if (!nm) { free(msg); close(fd); if (errbuf) snprintf(errbuf, errbuf_len, "out of memory"); return -1; }
            msg = nm;
        }
        memcpy(msg + off, fields[i], alen - 1);
        msg[off + alen - 1] = '\0';
        off += alen;
    }

    int rc = send_all(fd, msg, off);
    free(msg);
    if (rc != 0) {
        if (errbuf) snprintf(errbuf, errbuf_len, "send(): %s", strerror(errno));
        close(fd);
        return -1;
    }
    return fd;
}
