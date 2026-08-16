#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

#include "mtp_transfer.h"
#include "xmenu.h"
#include "notify.h"
#include "progress.h"
#include "config.h"

typedef enum { CONFLICT_REPLACE, CONFLICT_RENAME, CONFLICT_SKIP, CONFLICT_CANCEL } ConflictChoice;

static int path_exists(const char *p) {
    struct stat st;
    return stat(p, &st) == 0;
}

static void build_renamed_path(const char *dest_dir, const char *base_name, char *out, size_t outlen) {
    const char *dot = strrchr(base_name, '.');
    char stem[512], ext[128];
    if (dot && dot != base_name) {
        size_t stemlen = (size_t)(dot - base_name);
        if (stemlen >= sizeof(stem)) stemlen = sizeof(stem) - 1;
        memcpy(stem, base_name, stemlen);
        stem[stemlen] = '\0';
        snprintf(ext, sizeof(ext), "%s", dot);
    } else {
        snprintf(stem, sizeof(stem), "%s", base_name);
        ext[0] = '\0';
    }
    for (int i = 1; i < 10000; i++) {
        snprintf(out, outlen, "%s/%s (%d)%s", dest_dir, stem, i, ext);
        if (!path_exists(out)) return;
    }
}

static ConflictChoice ask_conflict(Display *dpy, int x, int y, const char *filename) {
#if MTP_CONFLICT_MODE == MTP_CONFLICT_ALWAYS_REPLACE
    (void)dpy; (void)x; (void)y; (void)filename;
    return CONFLICT_REPLACE;
#elif MTP_CONFLICT_MODE == MTP_CONFLICT_ALWAYS_RENAME
    (void)dpy; (void)x; (void)y; (void)filename;
    return CONFLICT_RENAME;
#elif MTP_CONFLICT_MODE == MTP_CONFLICT_ALWAYS_SKIP
    (void)dpy; (void)x; (void)y; (void)filename;
    return CONFLICT_SKIP;
#else
    char title[500];
    snprintf(title, sizeof(title), "\"%s\" already exists at the destination", filename);
    MenuItem items[5] = {
        { title, -1, 0, NULL, 0 },
        { "Replace", 0, 1, NULL, 0 },
        { "Rename (numbered)", 1, 1, NULL, 0 },
        { "Skip", 2, 1, NULL, 0 },
        { "Cancel Remaining", 3, 1, NULL, 0 },
    };
    const char *label = NULL;
    int id = xmenu_show(dpy, x, y, items, 5, &label);
    switch (id) {
        case 0: return CONFLICT_REPLACE;
        case 1: return CONFLICT_RENAME;
        case 2: return CONFLICT_SKIP;
        default: return CONFLICT_CANCEL;
    }
#endif
}

static int copy_one(const char *src, const char *dst, unsigned long long *cumulative,
                     unsigned long long total_size, ProgressWindow *pw, const char *disp_name) {
    int fdin = open(src, O_RDONLY);
    if (fdin < 0) return 0;
    int fdout = open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fdout < 0) { close(fdin); return 0; }

    char buf[65536];
    ssize_t n;
    int ok = 1;
    while ((n = read(fdin, buf, sizeof(buf))) > 0) {
        ssize_t off = 0;
        while (off < n) {
            ssize_t w = write(fdout, buf + off, (size_t)(n - off));
            if (w < 0) { ok = 0; break; }
            off += w;
        }
        if (!ok) break;
        *cumulative += (unsigned long long)n;
        progress_update(pw, disp_name, total_size ? (double)*cumulative / (double)total_size : 1.0);
    }
    if (n < 0) ok = 0;

    close(fdin);
    close(fdout);
    if (!ok) unlink(dst);
    return ok;
}

void mtp_transfer_copy_files(Display *dpy, int x, int y, char **src_paths, int count, const char *dest_dir) {
    if (count <= 0 || !dest_dir) return;

    unsigned long long total_size = 0;
    for (int i = 0; i < count; i++) {
        struct stat st;
        if (stat(src_paths[i], &st) == 0) total_size += (unsigned long long)st.st_size;
    }

    ProgressWindow *pw = progress_open(dpy, x, y, "Copying files...");

    unsigned long long cumulative = 0;
    int copied = 0, skipped = 0, failed = 0, cancelled_remaining = 0;

    for (int i = 0; i < count; i++) {
        const char *base = strrchr(src_paths[i], '/');
        base = base ? base + 1 : src_paths[i];

        char dst[2048];
        snprintf(dst, sizeof(dst), "%s/%s", dest_dir, base);

        if (path_exists(dst)) {
            ConflictChoice c = ask_conflict(dpy, x, y, base);
            if (c == CONFLICT_SKIP) { skipped++; continue; }
            if (c == CONFLICT_CANCEL) { cancelled_remaining = count - i; break; }
            if (c == CONFLICT_RENAME) {
                char renamed[2048];
                build_renamed_path(dest_dir, base, renamed, sizeof(renamed));
                snprintf(dst, sizeof(dst), "%s", renamed);
            }
            /* CONFLICT_REPLACE: dst stays as-is, O_TRUNC in copy_one overwrites it */
        }

        if (copy_one(src_paths[i], dst, &cumulative, total_size, pw, base)) copied++;
        else failed++;
    }

    progress_close(pw);

    if (NOTIFY_ON_MTP_TRANSFER_COMPLETE) {
        char body[350];
        snprintf(body, sizeof(body), "%d file%s copied%s%s%s", copied, copied == 1 ? "" : "s",
                 skipped ? ", some skipped" : "",
                 failed ? ", some failed" : "",
                 cancelled_remaining ? ", cancelled" : "");
        ud_notify("Transfer Complete", body);
    }
}
