/*
 * xmenu.c
 *
 * A minimal, dependency-light popup context menu drawn directly with
 * Xlib + Xft, in the spirit of suckless-style tools like xmenu/pmenu.
 * No toolkit, no rofi/dmenu process spawn -- just a borderless
 * override-redirect window, a pointer+keyboard grab for modal
 * behavior, and Xft for anti-aliased Unicode text (so Nerd Font icon
 * glyphs render correctly, unlike bitmap core fonts).
 *
 * Submenus are just recursive calls to menu_run() that open a second
 * popup window positioned beside the parent item; backing out of a
 * submenu (Escape / Left / click outside it) simply returns control to
 * the parent loop, which redraws itself and keeps running.
 *
 * MENU_RTL (config.h) mirrors the whole thing: the menu anchors its
 * top-right corner to (x,y) instead of top-left, submenus open to the
 * left of their parent instead of the right, the submenu arrow is a
 * prefix instead of a suffix, and row text is right-aligned.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <limits.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/Xft/Xft.h>
#include <X11/extensions/shape.h>

#include "xmenu.h"
#include "config.h"

typedef struct {
    Display *dpy;
    int screen;
    Window root;
    Visual *visual;
    Colormap cmap;
    XftFont *font;
    XftColor fg, bg, border, sel_bg, sel_fg, disabled_fg;
} MenuCtx;

typedef struct {
    int top;
    int height;
    int is_sep;
} RowLayout;

/* Clips the window's actual bounding shape to a rounded rectangle via
 * the X Shape extension, so the window IS rounded at the X server
 * level -- there's no ambiguity for the compositor to get wrong, since
 * it's not guessing at a mask over content it assumes is rectangular.
 * MENU_CORNER_RADIUS in config.h controls this; 0 disables it (plain
 * rectangle). One rectangle per row is simple and plenty fast for a
 * menu-sized window. */
static void apply_rounded_shape(Display *dpy, Window win, int w, int h, int radius) {
    if (radius <= 0 || w <= 0 || h <= 0) return;
    if (radius > w / 2) radius = w / 2;
    if (radius > h / 2) radius = h / 2;
    if (radius <= 0) return;

    XRectangle *rects = malloc(sizeof(XRectangle) * (size_t)h);
    if (!rects) return;

    for (int y = 0; y < h; y++) {
        int dy = 0;
        if (y < radius) {
            dy = radius - y;
        } else if (y >= h - radius) {
            dy = radius - (h - 1 - y);
        }

        int inset = 0;
        if (dy > 0) {
            double dx = sqrt((double)(radius * radius) - (double)(dy * dy));
            inset = radius - (int)dx;
            if (inset < 0) inset = 0;
        }

        rects[y].x = (short)inset;
        rects[y].y = (short)y;
        rects[y].width = (unsigned short)(w - 2 * inset);
        rects[y].height = 1;
    }

    XShapeCombineRectangles(dpy, win, ShapeBounding, 0, 0, rects, h, ShapeSet, Unsorted);
    free(rects);
}

static int text_width(MenuCtx *ctx, const char *s) {
    XGlyphInfo extents;
    XftTextExtentsUtf8(ctx->dpy, ctx->font, (const FcChar8 *)s, (int)strlen(s), &extents);
    return extents.xOff;
}

/* Returns 1 if byte c starts a new UTF-8 code point (not a
 * 10xxxxxx continuation byte). Used so truncation never lands
 * mid-character. */
static int utf8_is_lead(unsigned char c) {
    return (c & 0xC0) != 0x80;
}

/* Truncates `src` (UTF-8) to fit within max_px when rendered, always
 * cutting on a character boundary, appending "..." if it had to
 * shorten anything. */
static void truncate_to_width(MenuCtx *ctx, char *buf, size_t buflen, const char *src, int max_px) {
    if (max_px <= 0) {
        buf[0] = '\0';
        return;
    }
    if (text_width(ctx, src) <= max_px) {
        snprintf(buf, buflen, "%s", src);
        return;
    }

    int ellipsis_w = text_width(ctx, "...");
    int budget = max_px - ellipsis_w;
    if (budget < 0) budget = 0;

    size_t cut = strlen(src);
    while (cut > 0) {
        while (cut > 0 && !utf8_is_lead((unsigned char)src[cut])) cut--;
        if (cut == 0) break;

        char tmp[512];
        size_t n = cut < sizeof(tmp) - 1 ? cut : sizeof(tmp) - 1;
        memcpy(tmp, src, n);
        tmp[n] = '\0';

        if (text_width(ctx, tmp) <= budget) {
            snprintf(buf, buflen, "%s...", tmp);
            return;
        }
        cut--;
    }
    snprintf(buf, buflen, "...");
}

/* Builds the full row text (label + submenu arrow), truncating only
 * the label portion (never the arrow) to fit within available_px.
 * Pass INT_MAX during the layout/measurement pass to get the natural,
 * untruncated size. */
static void build_label(MenuCtx *ctx, char *buf, size_t buflen, const MenuItem *it, int available_px) {
    const char *label = it->label ? it->label : "";
    const char *arrow = (it->submenu_count > 0) ? (MENU_RTL ? MENU_SUBMENU_ARROW_RTL : MENU_SUBMENU_ARROW) : "";
    int arrow_w = arrow[0] ? text_width(ctx, arrow) : 0;

    int budget = available_px - arrow_w;
    if (budget < 0) budget = 0;

    char truncated[512];
    truncate_to_width(ctx, truncated, sizeof(truncated), label, budget);

    if (arrow[0] && MENU_RTL) {
        snprintf(buf, buflen, "%s%s", arrow, truncated);
    } else if (arrow[0]) {
        snprintf(buf, buflen, "%s%s", truncated, arrow);
    } else {
        snprintf(buf, buflen, "%s", truncated);
    }
}

static void layout_menu(MenuCtx *ctx, MenuItem *items, int count,
                         RowLayout *rows, int *out_width, int *out_height) {
    int row_h = ctx->font->ascent + ctx->font->descent + 2 * MENU_ITEM_PAD_Y;
    int sep_h = MENU_ITEM_PAD_Y * 2;
    int max_w = 0;
    int y = 0;

    for (int i = 0; i < count; i++) {
        if (items[i].label == NULL) {
            rows[i].top = y;
            rows[i].height = sep_h;
            rows[i].is_sep = 1;
            y += sep_h;
            continue;
        }
        char buf[512];
        build_label(ctx, buf, sizeof(buf), &items[i], INT_MAX);
        int w = text_width(ctx, buf);
        if (w > max_w) max_w = w;
        rows[i].top = y;
        rows[i].height = row_h;
        rows[i].is_sep = 0;
        y += row_h;
    }

    int content_w = max_w + 2 * MENU_ITEM_PAD_X;
    if (content_w < MENU_MIN_WIDTH) content_w = MENU_MIN_WIDTH;
    if (MENU_MAX_WIDTH > 0 && content_w > MENU_MAX_WIDTH) content_w = MENU_MAX_WIDTH;

    *out_width = content_w;
    *out_height = y;
}

static void fill_rounded_rect(Display *dpy, Drawable d, GC gc, XftColor *color,
                               int x, int y, int w, int h, int radius) {
    XSetForeground(dpy, gc, color->pixel);

    if (radius <= 0 || w <= 0 || h <= 0) {
        XFillRectangle(dpy, d, gc, x, y, (unsigned)w, (unsigned)h);
        return;
    }
    if (radius > w / 2) radius = w / 2;
    if (radius > h / 2) radius = h / 2;

    /* Same row-by-row inset math as apply_rounded_shape(), on purpose:
     * using XFillArc here (a different circle algorithm than the
     * shape mask's) left the fill and the window's actual clipped
     * shape very slightly misaligned, which is what made the corners
     * look jagged/uneven rather than just "not anti-aliased". Sharing
     * one formula guarantees the two line up exactly. */
    for (int row = 0; row < h; row++) {
        int dy = 0;
        if (row < radius) {
            dy = radius - row;
        } else if (row >= h - radius) {
            dy = radius - (h - 1 - row);
        }

        int inset = 0;
        if (dy > 0) {
            double dx = sqrt((double)(radius * radius) - (double)(dy * dy));
            inset = radius - (int)dx;
            if (inset < 0) inset = 0;
        }

        XFillRectangle(dpy, d, gc, x + inset, y + row, (unsigned)(w - 2 * inset), 1);
    }
}

static void draw_menu(MenuCtx *ctx, XftDraw *draw, GC gc, Window win, MenuItem *items, int count,
                       RowLayout *rows, int content_w, int content_h, int selected) {
    int bw = MENU_BORDER_WIDTH;

    fill_rounded_rect(ctx->dpy, win, gc, &ctx->border, 0, 0, content_w + 2 * bw, content_h + 2 * bw, MENU_CORNER_RADIUS);
    fill_rounded_rect(ctx->dpy, win, gc, &ctx->bg, bw, bw, content_w, content_h, MENU_CORNER_RADIUS);

    int available_px = content_w - 2 * MENU_ITEM_PAD_X;

    for (int i = 0; i < count; i++) {
        int row_top = bw + rows[i].top;

        if (rows[i].is_sep) {
            int mid = row_top + rows[i].height / 2;
            XftDrawRect(draw, &ctx->fg, bw + MENU_ITEM_PAD_X, mid,
                        (unsigned)(content_w - 2 * MENU_ITEM_PAD_X), 1);
            continue;
        }

        int is_selected = (i == selected) && items[i].enabled;
        if (is_selected) {
            XftDrawRect(draw, &ctx->sel_bg, bw, row_top, (unsigned)content_w, (unsigned)rows[i].height);
        }

        char buf[512];
        build_label(ctx, buf, sizeof(buf), &items[i], available_px);

        XftColor *color = !items[i].enabled ? &ctx->disabled_fg
                          : is_selected ? &ctx->sel_fg : &ctx->fg;

        int text_w = text_width(ctx, buf);
        int x_start = MENU_RTL ? (bw + content_w - MENU_ITEM_PAD_X - text_w) : (bw + MENU_ITEM_PAD_X);

        int baseline = row_top + MENU_ITEM_PAD_Y + ctx->font->ascent;
        XftDrawStringUtf8(draw, color, ctx->font, x_start, baseline,
                           (const FcChar8 *)buf, (int)strlen(buf));
    }
}

static int row_at_y(RowLayout *rows, int count, int y_in_content) {
    for (int i = 0; i < count; i++) {
        if (rows[i].is_sep) continue;
        if (y_in_content >= rows[i].top && y_in_content < rows[i].top + rows[i].height) {
            return i;
        }
    }
    return -1;
}

static int next_selectable(MenuItem *items, RowLayout *rows, int count, int from, int dir) {
    if (count == 0) return -1;
    int i = from;
    for (int n = 0; n < count; n++) {
        i += dir;
        if (i < 0) i = count - 1;
        if (i >= count) i = 0;
        if (!rows[i].is_sep && items[i].enabled) return i;
    }
    return -1;
}

static void grab_all(MenuCtx *ctx, Window win) {
    XGrabPointer(ctx->dpy, win, False,
                 ButtonPressMask | ButtonReleaseMask | PointerMotionMask,
                 GrabModeAsync, GrabModeAsync, None, None, CurrentTime);
    XGrabKeyboard(ctx->dpy, win, False, GrabModeAsync, GrabModeAsync, CurrentTime);
}

static int menu_run(MenuCtx *ctx, int x, int y, MenuItem *items, int count,
                     const char **out_label);

/* Returns the anchor x/y for a submenu given its parent item's
 * geometry. In LTR mode this is the parent's right edge (submenu
 * opens rightward); in RTL mode it's the parent's left edge (submenu
 * opens leftward) -- menu_run's own RTL handling then does the actual
 * left/right placement math uniformly for top-level menus and
 * submenus alike. */
static int open_submenu(MenuCtx *ctx, int parent_x, int parent_y, int parent_w,
                         int row_top, MenuItem *item, const char **out_label) {
    int sx = MENU_RTL ? (parent_x + MENU_SUBMENU_OVERLAP_X)
                       : (parent_x + parent_w - MENU_SUBMENU_OVERLAP_X);
    int sy = parent_y + row_top;
    return menu_run(ctx, sx, sy, item->submenu, item->submenu_count, out_label);
}

static int menu_run(MenuCtx *ctx, int x, int y, MenuItem *items, int count,
                     const char **out_label) {
    if (out_label) *out_label = NULL;
    if (count <= 0) return -1;

    RowLayout *rows = calloc((size_t)count, sizeof(RowLayout));
    if (!rows) return -1;

    int content_w, content_h;
    layout_menu(ctx, items, count, rows, &content_w, &content_h);

    int bw = MENU_BORDER_WIDTH;
    int win_w = content_w + 2 * bw;
    int win_h = content_h + 2 * bw;

    /* (x, y) is the anchor corner: top-left in LTR, top-right in RTL. */
    if (MENU_RTL) x -= win_w;

    int screen_w = DisplayWidth(ctx->dpy, ctx->screen);
    int screen_h = DisplayHeight(ctx->dpy, ctx->screen);
    if (x + win_w > screen_w) x = screen_w - win_w;
    if (y + win_h > screen_h) y = screen_h - win_h;
    if (x < 0) x = 0;
    if (y < 0) y = 0;

    XSetWindowAttributes attrs;
    attrs.override_redirect = True;
    attrs.background_pixel = ctx->bg.pixel;
    attrs.event_mask = ExposureMask | KeyPressMask | ButtonPressMask |
                        ButtonReleaseMask | PointerMotionMask | StructureNotifyMask;

    Window win = XCreateWindow(ctx->dpy, ctx->root, x, y, (unsigned)win_w, (unsigned)win_h, 0,
                                CopyFromParent, InputOutput, ctx->visual,
                                CWOverrideRedirect | CWBackPixel | CWEventMask, &attrs);

    apply_rounded_shape(ctx->dpy, win, win_w, win_h, MENU_CORNER_RADIUS);

    GC gc = XCreateGC(ctx->dpy, win, 0, NULL);

    XftDraw *draw = XftDrawCreate(ctx->dpy, win, ctx->visual, ctx->cmap);

    XMapRaised(ctx->dpy, win);
    XFlush(ctx->dpy);
    grab_all(ctx, win);

    int selected = next_selectable(items, rows, count, -1, 1);
    int result = -1;
    int done = 0;

    while (!done) {
        XEvent ev;
        XNextEvent(ctx->dpy, &ev);

        switch (ev.type) {
        case Expose:
            draw_menu(ctx, draw, gc, win, items, count, rows, content_w, content_h, selected);
            break;

        case MotionNotify: {
            int cy = ev.xmotion.y - bw;
            int row = row_at_y(rows, count, cy);
            if (row != selected) {
                selected = row;
                draw_menu(ctx, draw, gc, win, items, count, rows, content_w, content_h, selected);
            }
            break;
        }

        case ButtonRelease: {
            if (ev.xbutton.x < 0 || ev.xbutton.x > win_w ||
                ev.xbutton.y < 0 || ev.xbutton.y > win_h) {
                result = -1;
                done = 1;
                break;
            }
            int cy = ev.xbutton.y - bw;
            int row = row_at_y(rows, count, cy);
            if (row < 0 || !items[row].enabled) break;

            if (items[row].submenu_count > 0) {
                const char *sub_label = NULL;
                int sub_id = open_submenu(ctx, x, y, win_w, rows[row].top, &items[row], &sub_label);
                grab_all(ctx, win);
                draw_menu(ctx, draw, gc, win, items, count, rows, content_w, content_h, selected);
                if (sub_id >= 0) {
                    result = sub_id;
                    if (out_label) *out_label = sub_label;
                    done = 1;
                }
            } else {
                result = items[row].id;
                if (out_label) *out_label = items[row].label;
                done = 1;
            }
            break;
        }

        case KeyPress: {
            KeySym ks = XLookupKeysym(&ev.xkey, 0);
            /* In RTL mode, Left/Right swap meaning: Left opens a
             * submenu (matches the arrow now pointing left), Right
             * backs out. */
            KeySym open_key = MENU_RTL ? XK_Left : XK_Right;
            KeySym back_key = MENU_RTL ? XK_Right : XK_Left;

            if (ks == XK_Escape || ks == XK_q) {
                result = -1;
                done = 1;
            } else if (ks == XK_Down || ks == XK_j) {
                selected = next_selectable(items, rows, count, selected, 1);
                draw_menu(ctx, draw, gc, win, items, count, rows, content_w, content_h, selected);
            } else if (ks == XK_Up || ks == XK_k) {
                selected = next_selectable(items, rows, count, selected, -1);
                draw_menu(ctx, draw, gc, win, items, count, rows, content_w, content_h, selected);
            } else if (ks == back_key || (!MENU_RTL && ks == XK_h) || (MENU_RTL && ks == XK_l)) {
                result = -1;
                done = 1;
            } else if (ks == open_key || (!MENU_RTL && ks == XK_l) || (MENU_RTL && ks == XK_h) ||
                       ks == XK_Return || ks == XK_KP_Enter) {
                if (selected >= 0 && items[selected].enabled) {
                    if (items[selected].submenu_count > 0) {
                        const char *sub_label = NULL;
                        int sub_id = open_submenu(ctx, x, y, win_w, rows[selected].top,
                                                   &items[selected], &sub_label);
                        grab_all(ctx, win);
                        draw_menu(ctx, draw, gc, win, items, count, rows, content_w, content_h, selected);
                        if (sub_id >= 0) {
                            result = sub_id;
                            if (out_label) *out_label = sub_label;
                            done = 1;
                        }
                    } else {
                        result = items[selected].id;
                        if (out_label) *out_label = items[selected].label;
                        done = 1;
                    }
                }
            }
            break;
        }

        default:
            break;
        }
    }

    XUngrabKeyboard(ctx->dpy, CurrentTime);
    XUngrabPointer(ctx->dpy, CurrentTime);
    XftDrawDestroy(draw);
    XFreeGC(ctx->dpy, gc);
    XDestroyWindow(ctx->dpy, win);
    XFlush(ctx->dpy);
    free(rows);

    return result;
}

int xmenu_show(Display *dpy, int x, int y, MenuItem *items, int count, const char **out_label) {
    if (out_label) *out_label = NULL;
    if (!dpy || count <= 0) return -1;

    MenuCtx ctx;
    ctx.dpy = dpy;
    ctx.screen = DefaultScreen(dpy);
    ctx.root = RootWindow(dpy, ctx.screen);
    ctx.visual = DefaultVisual(dpy, ctx.screen);
    ctx.cmap = DefaultColormap(dpy, ctx.screen);

    ctx.font = XftFontOpenName(dpy, ctx.screen, MENU_FONT);
    if (!ctx.font) {
        fprintf(stderr, "xmenu: could not open font \"%s\"\n", MENU_FONT);
        return -1;
    }

    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_FG, &ctx.fg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_BG, &ctx.bg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_BORDER, &ctx.border);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_SELECT_BG, &ctx.sel_bg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_SELECT_FG, &ctx.sel_fg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_DISABLED_FG, &ctx.disabled_fg);

    int result = menu_run(&ctx, x, y, items, count, out_label);

    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.fg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.bg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.border);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.sel_bg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.sel_fg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.disabled_fg);
    XftFontClose(dpy, ctx.font);

    return result;
}
