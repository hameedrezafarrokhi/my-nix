#include "common.h"
#include "config.h"
#include "ipc.h"
#include "xclass.h"
#include "rescan.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <poll.h>
#include <signal.h>
#include <sys/signalfd.h>
#include <sys/stat.h>

log_level_t g_log_level = LOG_LVL_INFO;

#define PATH_MAX_LOCAL 4096
#define PROGRAM_NAME "bspi"
#define DEBOUNCE_MS_DEFAULT 50
#define MAX_COALESCE_MS 250
#define RECONNECT_BACKOFF_MIN_MS 200
#define RECONNECT_BACKOFF_MAX_MS 5000

static const char *const SUBSCRIBE_FIELDS[] = {
    "node_add", "node_remove", "node_transfer", "node_swap", "node_flag",
    "desktop_add", "desktop_remove", "desktop_swap", "desktop_transfer",
    "desktop_focus", "desktop_activate",
    "monitor_add", "monitor_remove",
};
#define SUBSCRIBE_FIELDS_COUNT (sizeof(SUBSCRIBE_FIELDS) / sizeof(SUBSCRIBE_FIELDS[0]))

typedef struct {
    const char *config_arg;
    const char *socket_arg;
    int debounce_ms;
    int once;
    int verbose;
} options_t;

static void print_usage(void) {
    printf(
        "Usage: " PROGRAM_NAME " [options]\n"
        "\n"
        "Renames bspwm desktops with icons based on the applications running\n"
        "on them. Runs as a persistent daemon by default, reacting to bspwm\n"
        "events directly over its socket.\n"
        "\n"
        "Options:\n"
        "  -c, --config PATH     Path to bspi.ini (see below for the default search order)\n"
        "      --socket PATH     Path to bspwm's socket (default: $BSPWM_SOCKET)\n"
        "      --debounce MS     Coalesce bursts of events for this many ms (default: %d)\n"
        "      --once            Do a single rescan and exit, instead of running as a daemon\n"
        "  -v, --verbose         Increase log verbosity (repeatable)\n"
        "  -h, --help            Show this help and exit\n"
        "\n"
        "Without -c/--config, bspi looks for bspi.ini in:\n"
        "  1. $XDG_CONFIG_HOME/bspi/bspi.ini\n"
        "  2. ~/.config/bspi/bspi.ini\n"
        "  3. the directory containing the bspi executable itself\n",
        DEBOUNCE_MS_DEFAULT);
}

static int file_exists(const char *path) {
    struct stat st;
    return path && *path && stat(path, &st) == 0 && S_ISREG(st.st_mode);
}

/* Tries, in order: $XDG_CONFIG_HOME/bspi/bspi.ini, ~/.config/bspi/bspi.ini,
 * and finally next to the running executable (matching where the
 * original Python script looked, for people upgrading in place). */
static int resolve_default_config_path(char *out, size_t out_len) {
    const char *xdg = getenv("XDG_CONFIG_HOME");
    if (xdg && *xdg) {
        snprintf(out, out_len, "%s/bspi/bspi.ini", xdg);
        if (file_exists(out)) return 0;
    }

    const char *home = getenv("HOME");
    if (home && *home) {
        snprintf(out, out_len, "%s/.config/bspi/bspi.ini", home);
        if (file_exists(out)) return 0;
    }

    char exe_path[PATH_MAX_LOCAL - 32];
    ssize_t n = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
    if (n > 0) {
        exe_path[n] = '\0';
        char *slash = strrchr(exe_path, '/');
        if (slash) *slash = '\0';
        snprintf(out, out_len, "%s/bspi.ini", exe_path);
        if (file_exists(out)) return 0;
    }

    return -1;
}

static volatile sig_atomic_t g_should_exit = 0;
static volatile sig_atomic_t g_should_reload = 0;

static long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}

/* One (re)connect-and-serve cycle. Returns when the subscribe
 * connection drops (bspwm restarted, etc) or we're told to exit.
 * Caller decides whether/how to reconnect. */
static void serve(const char *sock_path, bspi_config_t *cfg, xclass_ctx_t **xctx,
                   const char *config_path, int debounce_ms, int sigfd) {
    int sub_fd = bspwm_subscribe_open(sock_path, SUBSCRIBE_FIELDS, (int)SUBSCRIBE_FIELDS_COUNT,
                                       NULL, 0);
    if (sub_fd < 0) {
        LOGW("could not subscribe to bspwm events");
        return;
    }
    LOGI("subscribed to bspwm events");

    /* Bring desktop names up to date immediately on (re)connect,
     * rather than waiting for the next event. */
    bspi_rescan(sock_path, cfg, *xctx);

    int pending = 0;
    long first_pending_ms = 0;
    long last_pending_ms = 0;

    for (;;) {
        struct pollfd fds[2] = {
            { .fd = sub_fd, .events = POLLIN },
            { .fd = sigfd,  .events = POLLIN },
        };

        int timeout_ms = -1;
        if (pending) {
            long now = now_ms();
            long fire_by_debounce = last_pending_ms + debounce_ms;
            long fire_by_cap = first_pending_ms + MAX_COALESCE_MS;
            long fire_at = fire_by_debounce < fire_by_cap ? fire_by_debounce : fire_by_cap;
            timeout_ms = (int)(fire_at - now);
            if (timeout_ms < 0) timeout_ms = 0;
        }

        int rc = poll(fds, 2, timeout_ms);
        if (rc < 0) {
            if (errno == EINTR) continue;
            LOGW("poll() failed: %s", strerror(errno));
            break;
        }

        if (fds[1].revents & POLLIN) {
            struct signalfd_siginfo si;
            while (read(sigfd, &si, sizeof(si)) == sizeof(si)) {
                if (si.ssi_signo == SIGHUP) {
                    g_should_reload = 1;
                } else {
                    g_should_exit = 1;
                }
            }
        }

        if (g_should_reload) {
            g_should_reload = 0;
            LOGI("reloading config from '%s'", config_path);
            bspi_config_t fresh;
            char errbuf[256];
            if (bspi_config_load(&fresh, config_path, errbuf, sizeof(errbuf)) == 0) {
                bspi_config_free(cfg);
                *cfg = fresh;
                LOGI("config reloaded (%zu icon entries)", cfg->icons.count);
                bspi_rescan(sock_path, cfg, *xctx);
            } else {
                LOGW("failed to reload config, keeping the old one: %s", errbuf);
            }
        }

        if (g_should_exit) break;

        if (fds[0].revents & (POLLHUP | POLLERR)) {
            LOGW("lost connection to bspwm's subscribe socket");
            break;
        }

        if (fds[0].revents & POLLIN) {
            char buf[4096];
            ssize_t n = read(sub_fd, buf, sizeof(buf));
            if (n <= 0) {
                LOGW("bspwm's subscribe socket closed");
                break;
            }
            long now = now_ms();
            if (!pending) {
                pending = 1;
                first_pending_ms = now;
            }
            last_pending_ms = now;
        }

        if (rc == 0 && pending) {
            /* Debounce window elapsed (or we hit the coalescing cap):
             * a good moment to actually recompute names. */
            if ((*xctx) && xclass_broken(*xctx)) {
                xclass_close(*xctx);
                *xctx = xclass_open();
            }
            bspi_rescan(sock_path, cfg, *xctx);
            pending = 0;
        }
    }

    close(sub_fd);
}

int main(int argc, char **argv) {
    options_t opt = {
        .config_arg = NULL,
        .socket_arg = NULL,
        .debounce_ms = DEBOUNCE_MS_DEFAULT,
        .once = 0,
        .verbose = 0,
    };

    for (int i = 1; i < argc; i++) {
        const char *a = argv[i];
        if ((strcmp(a, "-c") == 0 || strcmp(a, "--config") == 0) && i + 1 < argc) {
            opt.config_arg = argv[++i];
        } else if (strcmp(a, "--socket") == 0 && i + 1 < argc) {
            opt.socket_arg = argv[++i];
        } else if (strcmp(a, "--debounce") == 0 && i + 1 < argc) {
            opt.debounce_ms = atoi(argv[++i]);
        } else if (strcmp(a, "--once") == 0) {
            opt.once = 1;
        } else if (strcmp(a, "-v") == 0 || strcmp(a, "--verbose") == 0) {
            opt.verbose++;
        } else if (strcmp(a, "-h") == 0 || strcmp(a, "--help") == 0) {
            print_usage();
            return 0;
        } else {
            fprintf(stderr, "unrecognized option: %s\n\n", a);
            print_usage();
            return 2;
        }
    }

    if (opt.verbose >= 2) g_log_level = LOG_LVL_DEBUG;
    else if (opt.verbose == 1) g_log_level = LOG_LVL_INFO;

    char config_path[PATH_MAX_LOCAL];
    if (opt.config_arg) {
        snprintf(config_path, sizeof(config_path), "%s", opt.config_arg);
        if (!file_exists(config_path)) {
            LOGE("no file was found at the specified path for the configuration file: %s",
                 config_path);
            return 1;
        }
    } else if (resolve_default_config_path(config_path, sizeof(config_path)) != 0) {
        LOGE("could not find bspi.ini in any of the default locations "
             "(pass -c/--config to specify one explicitly)");
        return 1;
    }

    bspi_config_t cfg;
    char errbuf[256];
    if (bspi_config_load(&cfg, config_path, errbuf, sizeof(errbuf)) != 0) {
        LOGE("failed to load config: %s", errbuf);
        return 1;
    }
    LOGI("loaded config '%s' (%zu icon entries)", config_path, cfg.icons.count);

    char sock_path[PATH_MAX_LOCAL];
    if (bspwm_resolve_socket_path(opt.socket_arg, sock_path, sizeof(sock_path)) != 0) {
        LOGE("could not determine bspwm's socket path - is bspwm running? "
             "(try --socket to set it explicitly)");
        bspi_config_free(&cfg);
        return 1;
    }
    LOGI("using bspwm socket '%s'", sock_path);

    xclass_ctx_t *xctx = xclass_open(); /* may be NULL - handled gracefully throughout */

    if (opt.once) {
        int rc = bspi_rescan(sock_path, &cfg, xctx);
        xclass_close(xctx);
        bspi_config_free(&cfg);
        return rc == 0 ? 0 : 1;
    }

    sigset_t mask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);
    sigaddset(&mask, SIGTERM);
    sigaddset(&mask, SIGHUP);
    sigprocmask(SIG_BLOCK, &mask, NULL);
    int sigfd = signalfd(-1, &mask, SFD_NONBLOCK);
    if (sigfd < 0) {
        LOGE("signalfd() failed: %s", strerror(errno));
        xclass_close(xctx);
        bspi_config_free(&cfg);
        return 1;
    }

    int backoff_ms = RECONNECT_BACKOFF_MIN_MS;
    while (!g_should_exit) {
        serve(sock_path, &cfg, &xctx, config_path, opt.debounce_ms, sigfd);
        if (g_should_exit) break;

        LOGI("reconnecting to bspwm in %dms", backoff_ms);
        struct pollfd fds[1] = { { .fd = sigfd, .events = POLLIN } };
        poll(fds, 1, backoff_ms);
        if (fds[0].revents & POLLIN) {
            struct signalfd_siginfo si;
            while (read(sigfd, &si, sizeof(si)) == sizeof(si)) {
                if (si.ssi_signo == SIGHUP) g_should_reload = 1;
                else g_should_exit = 1;
            }
        }
        backoff_ms *= 2;
        if (backoff_ms > RECONNECT_BACKOFF_MAX_MS) backoff_ms = RECONNECT_BACKOFF_MAX_MS;
    }

    LOGI("shutting down");
    close(sigfd);
    xclass_close(xctx);
    bspi_config_free(&cfg);
    return 0;
}
