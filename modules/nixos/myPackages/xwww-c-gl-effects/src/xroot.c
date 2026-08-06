#include "xroot.h"
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_XSHM
#include <X11/extensions/XShm.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#endif

#ifdef HAVE_XINERAMA
#include <X11/extensions/Xinerama.h>
#endif

static Display *dpy = NULL;
static int      scr = 0;
static Window   root;
static Visual  *visual;
static int      depth;
static GC       gc;
static int      root_w, root_h;

static uint32_t rmask, gmask, bmask;
static int      rshift, gshift, bshift;
static int      fast_path = 0; /* 1 if we can do a tight 32bpp 0xRRGGBB store */

static int have_shm = 0;
#ifdef HAVE_XSHM
static XShmSegmentInfo shminfo;
#endif
static XImage *frame_img = NULL; /* reused every push, sized root_w x root_h */

/* The pixmap *this process* currently has set as the root background.
 * None until our first push. Freeing it is a plain XFreePixmap (no
 * XKillClient dance needed) because we -- the still-connected owner --
 * created it; that trick is only for a *previous process's* leftover. */
static Pixmap owned_pixmap = None;

static int shift_for_mask(uint32_t m) {
    int s = 0;
    if (!m) return 0;
    while (!(m & 1)) { m >>= 1; s++; }
    return s;
}

static void compute_mask_shifts(void) {
    rmask = visual->red_mask;
    gmask = visual->green_mask;
    bmask = visual->blue_mask;
    rshift = shift_for_mask(rmask);
    gshift = shift_for_mask(gmask);
    bshift = shift_for_mask(bmask);
    fast_path = (rmask == 0xFF0000 && gmask == 0x00FF00 && bmask == 0x0000FF);
}

/* Image buffer used to stage each frame's pixels before they're copied
 * into that frame's pixmap. Reused across frames (always root_w x
 * root_h, which never changes mid-run), so this is allocated once. */
static void ensure_frame_image(void) {
    if (frame_img) return;
#ifdef HAVE_XSHM
    if (XShmQueryExtension(dpy)) {
        XImage *img = XShmCreateImage(dpy, visual, depth, ZPixmap, NULL, &shminfo, root_w, root_h);
        if (img) {
            shminfo.shmid = shmget(IPC_PRIVATE, (size_t)img->bytes_per_line * img->height,
                                    IPC_CREAT | 0600);
            if (shminfo.shmid >= 0) {
                shminfo.shmaddr = img->data = shmat(shminfo.shmid, NULL, 0);
                shminfo.readOnly = False;
                if (XShmAttach(dpy, &shminfo)) {
                    XSync(dpy, False);
                    shmctl(shminfo.shmid, IPC_RMID, 0); /* auto-cleanup on detach */
                    have_shm = 1;
                    frame_img = img;
                    return;
                }
                shmdt(shminfo.shmaddr);
            }
            XDestroyImage(img);
        }
    }
#endif
    char *data = malloc((size_t)root_w * root_h * 4);
    frame_img = XCreateImage(dpy, visual, depth, ZPixmap, 0, data, root_w, root_h, 32, 0);
}

static void write_pixels(XImage *img, const buf_t *b) {
    int w = b->w, h = b->h;
    if (fast_path && img->bits_per_pixel == 32 && img->byte_order == (
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
            LSBFirst
#else
            MSBFirst
#endif
        )) {
        uint32_t *dst = (uint32_t *)img->data;
        int stride = img->bytes_per_line / 4;
        for (int y = 0; y < h; y++) {
            const uint32_t *srow = &b->pix[(size_t)y * w];
            uint32_t *drow = &dst[(size_t)y * stride];
            for (int x = 0; x < w; x++)
                drow[x] = srow[x] & 0x00FFFFFF; /* root has no use for alpha */
        }
    } else {
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                uint32_t p = b->pix[(size_t)y * w + x];
                uint8_t r = (p >> 16) & 0xFF, g = (p >> 8) & 0xFF, bl = p & 0xFF;
                unsigned long pixel = ((unsigned long)r << rshift & rmask) |
                                       ((unsigned long)g << gshift & gmask) |
                                       ((unsigned long)bl << bshift & bmask);
                XPutPixel(img, x, y, pixel);
            }
        }
    }
}

int xroot_init(void) {
    dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "xwww: cannot open X display\n");
        return -1;
    }
    /* Resources we create (the background pixmap in particular) must
     * outlive this short-lived process -- we are daemonless by design. */
    XSetCloseDownMode(dpy, RetainPermanent);

    scr = DefaultScreen(dpy);
    root = RootWindow(dpy, scr);
    visual = DefaultVisual(dpy, scr);
    depth = DefaultDepth(dpy, scr);
    gc = XCreateGC(dpy, root, 0, NULL);

    root_w = DisplayWidth(dpy, scr);
    root_h = DisplayHeight(dpy, scr);

    compute_mask_shifts();

    if (depth < 24) {
        fprintf(stderr, "xwww: warning: display depth %d < 24 is untested, "
                         "colors may be degraded\n", depth);
    }
    return 0;
}

void xroot_shutdown(void) {
    /* Deliberately do NOT free owned_pixmap here: it's the live wallpaper
     * background and must survive after this process exits (that's the
     * whole point of RetainPermanent). It gets reclaimed by the *next*
     * xwww run via xroot_reclaim_previous(). */
#ifdef HAVE_XSHM
    if (have_shm && frame_img) {
        XShmDetach(dpy, &shminfo);
        shmdt(shminfo.shmaddr);
        XDestroyImage(frame_img);
    } else
#endif
    if (frame_img) {
        XDestroyImage(frame_img);
    }
    if (dpy) { XFreeGC(dpy, gc); XCloseDisplay(dpy); }
}

void xroot_get_size(int *w, int *h) { *w = root_w; *h = root_h; }

int xroot_get_monitors(monitor_t *out, int max) {
#ifdef HAVE_XINERAMA
    if (XineramaIsActive(dpy)) {
        int n = 0;
        XineramaScreenInfo *info = XineramaQueryScreens(dpy, &n);
        int count = n < max ? n : max;
        for (int i = 0; i < count; i++) {
            snprintf(out[i].name, sizeof(out[i].name), "monitor-%d", i);
            out[i].x = info[i].x_org;
            out[i].y = info[i].y_org;
            out[i].w = info[i].width;
            out[i].h = info[i].height;
        }
        XFree(info);
        if (count > 0) return count;
    }
#endif
    if (max < 1) return 0;
    snprintf(out[0].name, sizeof(out[0].name), "root");
    out[0].x = 0; out[0].y = 0; out[0].w = root_w; out[0].h = root_h;
    return 1;
}

int xroot_capture(buf_t *out, int x, int y, int w, int h) {
    XImage *img = XGetImage(dpy, root, x, y, w, h, AllPlanes, ZPixmap);
    if (!img) {
        *out = buf_alloc(w, h);
        buf_fill(out, 0xFF000000);
        return -1;
    }
    *out = buf_alloc(w, h);
    if (fast_path && img->bits_per_pixel == 32) {
        uint32_t *src = (uint32_t *)img->data;
        int stride = img->bytes_per_line / 4;
        for (int yy = 0; yy < h; yy++) {
            const uint32_t *srow = &src[(size_t)yy * stride];
            uint32_t *drow = &out->pix[(size_t)yy * w];
            for (int xx = 0; xx < w; xx++)
                drow[xx] = 0xFF000000u | (srow[xx] & 0x00FFFFFFu);
        }
    } else {
        for (int yy = 0; yy < h; yy++)
            for (int xx = 0; xx < w; xx++) {
                unsigned long p = XGetPixel(img, xx, yy);
                uint8_t r = (uint8_t)((p & rmask) >> rshift);
                uint8_t g = (uint8_t)((p & gmask) >> gshift);
                uint8_t b = (uint8_t)((p & bmask) >> bshift);
                out->pix[(size_t)yy * w + xx] = px_pack(0xFF, r, g, b);
            }
    }
    XDestroyImage(img);
    return 0;
}

/* feh/hsetroot-style reclaim: if _XROOTPMAP_ID and ESETROOT_PMAP_ID agree
 * on a pixmap id, XKillClient it. That works even though the process
 * that created it (a prior, now-exited xwww run) is long gone, because
 * RetainPermanent left the resource owned by the server rather than any
 * client. Only needed once, for whatever we're inheriting; anything *we*
 * create after this is freed the cheap way (see xroot_push_frame). */
void xroot_reclaim_previous(void) {
    Atom prop_root = XInternAtom(dpy, "_XROOTPMAP_ID", True);
    Atom prop_ester = XInternAtom(dpy, "ESETROOT_PMAP_ID", True);
    if (prop_root == None || prop_ester == None) return;

    Atom type; int format; unsigned long len, after;
    unsigned char *data_root = NULL, *data_ester = NULL;

    XGetWindowProperty(dpy, root, prop_root, 0, 1, False, AnyPropertyType,
                        &type, &format, &len, &after, &data_root);
    if (type == XA_PIXMAP && data_root) {
        XGetWindowProperty(dpy, root, prop_ester, 0, 1, False, AnyPropertyType,
                            &type, &format, &len, &after, &data_ester);
        if (type == XA_PIXMAP && data_ester &&
            *(Pixmap *)data_root == *(Pixmap *)data_ester) {
            XKillClient(dpy, *(Pixmap *)data_root);
        }
    }
    if (data_root) XFree(data_root);
    if (data_ester) XFree(data_ester);
}

int xroot_push_frame(const buf_t *full_canvas) {
    ensure_frame_image();
    write_pixels(frame_img, full_canvas);

    Pixmap pm = XCreatePixmap(dpy, root, root_w, root_h, depth);
#ifdef HAVE_XSHM
    if (have_shm)
        XShmPutImage(dpy, pm, gc, frame_img, 0, 0, 0, 0, root_w, root_h, False);
    else
#endif
        XPutImage(dpy, pm, gc, frame_img, 0, 0, 0, 0, root_w, root_h);

    XSetWindowBackgroundPixmap(dpy, root, pm);
    XClearWindow(dpy, root);

    Atom prop_root = XInternAtom(dpy, "_XROOTPMAP_ID", False);
    Atom prop_ester = XInternAtom(dpy, "ESETROOT_PMAP_ID", False);
    XChangeProperty(dpy, root, prop_root, XA_PIXMAP, 32, PropModeReplace, (unsigned char *)&pm, 1);
    XChangeProperty(dpy, root, prop_ester, XA_PIXMAP, 32, PropModeReplace, (unsigned char *)&pm, 1);

    XFlush(dpy);
    if (have_shm) XSync(dpy, False); /* SHM buffer is about to be overwritten next frame */

    if (owned_pixmap != None) XFreePixmap(dpy, owned_pixmap);
    owned_pixmap = pm;
    return 0;
}
