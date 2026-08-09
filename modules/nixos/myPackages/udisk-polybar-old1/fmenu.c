/*
 * fmenu.c
 *
 * A dmenu/rofi-style filterable popup: a text input row for a search
 * query, and a scrollable list of results below it, clamped to the
 * screen height (so, unlike a plain xmenu list, it never runs off the
 * bottom of the screen -- it scrolls instead). Optional multi-select
 * via Tab/click-to-toggle plus Enter-to-confirm-the-checked-set.
 *
 * Filtering is a simple case-insensitive subsequence match (every
 * typed character must appear, in order, somewhere in the label) --
 * an approximation of fzf's basic mode, not its actual scoring
 * algorithm.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/Xft/Xft.h>
#include <X11/extensions/shape.h>

#include "fmenu.h"
#include "config.h"

typedef struct {
    Display *dpy;
    int screen;
    Visual *visual;
    Colormap cmap;
    XftFont *font;
    XftColor fg, bg, border, sel_bg, sel_fg, disabled_fg;
} FCtx;

/* See xmenu.c for the full explanation -- this clips the window's
 * real bounding shape via the X Shape extension instead of leaving it
 * to the compositor to guess at rounding over assumed-rectangular
 * content. Since fmenu resizes its window as filtering narrows the
 * result list, this must be reapplied after every resize. */
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

static int fuzzy_match(const char *needle, const char *haystack) {
    if (!*needle) return 1;
    const char *h = haystack;
    for (const char *n = needle; *n; n++) {
        int nc = tolower((unsigned char)*n);
        int found = 0;
        while (*h) {
            int hc = tolower((unsigned char)*h);
            h++;
            if (hc == nc) { found = 1; break; }
        }
        if (!found) return 0;
    }
    return 1;
}

static void recompute_filter(FMenuEntry *entries, int count, const char *query,
                              int *filtered, int *out_count) {
    int n = 0;
    for (int i = 0; i < count; i++) {
        if (fuzzy_match(query, entries[i].label)) filtered[n++] = i;
    }
    *out_count = n;
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

    /* Same row-by-row inset math as apply_rounded_shape() -- see the
     * comment in xmenu.c's copy of this function for why. */
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

static void draw_all(FCtx *ctx, XftDraw *xd, GC gc, Window win, int win_w, int win_h, int row_h, int bw,
                      const char *query, FMenuEntry *entries, int *filtered, int filtered_count,
                      int sel, int scroll_off, int visible_rows, int *checked_flags, int multi_select) {
    fill_rounded_rect(ctx->dpy, win, gc, &ctx->border, 0, 0, win_w, win_h, MENU_CORNER_RADIUS);
    fill_rounded_rect(ctx->dpy, win, gc, &ctx->bg, bw, bw, win_w - 2 * bw, win_h - 2 * bw, MENU_CORNER_RADIUS);

    char input_line[600];
    snprintf(input_line, sizeof(input_line), "%s%s", FMENU_PROMPT_ICON, query);
    int baseline = bw + MENU_ITEM_PAD_Y + ctx->font->ascent;
    XftDrawStringUtf8(xd, &ctx->fg, ctx->font, bw + MENU_ITEM_PAD_X, baseline,
                       (const FcChar8 *)input_line, (int)strlen(input_line));

    int sep_y = bw + row_h;
    XftDrawRect(xd, &ctx->border, bw, sep_y, (unsigned)(win_w - 2 * bw), 1);

    for (int row = 0; row < visible_rows; row++) {
        int fi = scroll_off + row;
        if (fi >= filtered_count) break;
        int entry_idx = filtered[fi];

        int row_top = sep_y + 1 + row * row_h;
        int is_selected = (fi == sel);
        if (is_selected) {
            XftDrawRect(xd, &ctx->sel_bg, bw, row_top, (unsigned)(win_w - 2 * bw), (unsigned)row_h);
        }

        char line[600];
        if (multi_select) {
            const char *mark = (checked_flags && checked_flags[entry_idx]) ? FMENU_CHECK_ON : FMENU_CHECK_OFF;
            snprintf(line, sizeof(line), "%s%s", mark, entries[entry_idx].label);
        } else {
            snprintf(line, sizeof(line), "%s", entries[entry_idx].label);
        }

        XftColor *color = is_selected ? &ctx->sel_fg : &ctx->fg;
        int rbaseline = row_top + MENU_ITEM_PAD_Y + ctx->font->ascent;
        XftDrawStringUtf8(xd, color, ctx->font, bw + MENU_ITEM_PAD_X, rbaseline,
                           (const FcChar8 *)line, (int)strlen(line));
    }
}

FMenuResult fmenu_show(Display *dpy, int x, int y, FMenuEntry *entries, int count, int multi_select) {
    FMenuResult result;
    result.index = -1;
    result.checked = NULL;
    result.checked_count = 0;

    if (!dpy || count <= 0) return result;

    FCtx ctx;
    ctx.dpy = dpy;
    ctx.screen = DefaultScreen(dpy);
    Window root = RootWindow(dpy, ctx.screen);
    ctx.visual = DefaultVisual(dpy, ctx.screen);
    ctx.cmap = DefaultColormap(dpy, ctx.screen);
    ctx.font = XftFontOpenName(dpy, ctx.screen, MENU_FONT);
    if (!ctx.font) return result;

    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_FG, &ctx.fg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_BG, &ctx.bg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_BORDER, &ctx.border);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_SELECT_BG, &ctx.sel_bg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_SELECT_FG, &ctx.sel_fg);
    XftColorAllocName(dpy, ctx.visual, ctx.cmap, MENU_COLOR_DISABLED_FG, &ctx.disabled_fg);

    int row_h = ctx.font->ascent + ctx.font->descent + 2 * MENU_ITEM_PAD_Y;
    int bw = MENU_BORDER_WIDTH;

    int screen_h = DisplayHeight(dpy, ctx.screen);
    int screen_w = DisplayWidth(dpy, ctx.screen);

    int max_visible = FMENU_MAX_VISIBLE_ROWS;
    int max_rows_for_screen = (screen_h - 2 * bw - row_h - 1) / row_h - 1;
    if (max_rows_for_screen < 1) max_rows_for_screen = 1;
    if (max_visible > max_rows_for_screen) max_visible = max_rows_for_screen;

    int win_w = FMENU_WIDTH;
    if (win_w > screen_w) win_w = screen_w;

    int *filtered = malloc(sizeof(int) * (size_t)count);
    int *checked_flags = multi_select ? calloc((size_t)count, sizeof(int)) : NULL;
    if (!filtered || (multi_select && !checked_flags)) {
        free(filtered);
        free(checked_flags);
        XftFontClose(dpy, ctx.font);
        return result;
    }

    char query[256];
    query[0] = '\0';
    size_t query_len = 0;

    int filtered_count = 0;
    recompute_filter(entries, count, query, filtered, &filtered_count);

    int visible_rows = filtered_count < max_visible ? filtered_count : max_visible;
    if (visible_rows < 1) visible_rows = 1;
    int win_h = bw + row_h + 1 + visible_rows * row_h + bw;

    if (FMENU_CENTERED) {
        x = (screen_w - win_w) / 2;
        y = (screen_h - win_h) / 2;
    }

    if (x + win_w > screen_w) x = screen_w - win_w;
    if (y + win_h > screen_h) y = screen_h - win_h;
    if (x < 0) x = 0;
    if (y < 0) y = 0;

    XSetWindowAttributes attrs;
    attrs.override_redirect = True;
    attrs.background_pixel = ctx.bg.pixel;
    attrs.event_mask = ExposureMask | KeyPressMask | ButtonPressMask |
                        ButtonReleaseMask | PointerMotionMask | StructureNotifyMask;

    Window win = XCreateWindow(dpy, root, x, y, (unsigned)win_w, (unsigned)win_h, 0,
                                CopyFromParent, InputOutput, ctx.visual,
                                CWOverrideRedirect | CWBackPixel | CWEventMask, &attrs);

    apply_rounded_shape(dpy, win, win_w, win_h, MENU_CORNER_RADIUS);

    GC gc = XCreateGC(dpy, win, 0, NULL);

    XftDraw *xd = XftDrawCreate(dpy, win, ctx.visual, ctx.cmap);

    XMapRaised(dpy, win);
    XFlush(dpy);
    XGrabPointer(dpy, win, False, ButtonPressMask | ButtonReleaseMask | PointerMotionMask,
                 GrabModeAsync, GrabModeAsync, None, None, CurrentTime);
    XGrabKeyboard(dpy, win, False, GrabModeAsync, GrabModeAsync, CurrentTime);

    int sel = 0;
    int scroll_off = 0;
    int done = 0;

    while (!done) {
        XEvent ev;
        XNextEvent(dpy, &ev);

        switch (ev.type) {
        case Expose:
            draw_all(&ctx, xd, gc, win, win_w, win_h, row_h, bw, query, entries,
                     filtered, filtered_count, sel, scroll_off, visible_rows, checked_flags, multi_select);
            break;

        case KeyPress: {
            char buf[32];
            KeySym ks = NoSymbol;
            int n = XLookupString(&ev.xkey, buf, (int)sizeof(buf) - 1, &ks, NULL);
            if (n < 0) n = 0;
            buf[n] = '\0';

            int need_refilter = 0;

            if (ks == XK_Escape) {
                result.index = -1;
                done = 1;

            } else if (ks == XK_Return || ks == XK_KP_Enter) {
                if (multi_select && checked_flags) {
                    int cc = 0;
                    for (int i = 0; i < count; i++) if (checked_flags[i]) cc++;
                    if (cc > 0) {
                        result.checked = malloc(sizeof(int) * (size_t)cc);
                        int k = 0;
                        for (int i = 0; i < count; i++) if (checked_flags[i]) result.checked[k++] = i;
                        result.checked_count = cc;
                        done = 1;
                        break;
                    }
                }
                if (filtered_count > 0) result.index = filtered[sel];
                done = 1;

            } else if (ks == XK_Tab && multi_select && filtered_count > 0) {
                checked_flags[filtered[sel]] = !checked_flags[filtered[sel]];

            } else if (ks == XK_Up || ks == XK_Down) {
                if (filtered_count > 0) {
                    if (ks == XK_Down) sel = (sel + 1) % filtered_count;
                    else sel = (sel - 1 + filtered_count) % filtered_count;
                    if (sel < scroll_off) scroll_off = sel;
                    if (sel >= scroll_off + visible_rows) scroll_off = sel - visible_rows + 1;
                }

            } else if (ks == XK_BackSpace) {
                if (query_len > 0) {
                    query[--query_len] = '\0';
                    need_refilter = 1;
                }

            } else if (n > 0 && (unsigned char)buf[0] >= 0x20 && (unsigned char)buf[0] != 0x7f) {
                if (query_len + (size_t)n < sizeof(query) - 1) {
                    memcpy(query + query_len, buf, (size_t)n);
                    query_len += (size_t)n;
                    query[query_len] = '\0';
                    need_refilter = 1;
                }
            }

            if (need_refilter) {
                recompute_filter(entries, count, query, filtered, &filtered_count);
                sel = 0;
                scroll_off = 0;
                visible_rows = filtered_count < max_visible ? filtered_count : max_visible;
                if (visible_rows < 1) visible_rows = 1;
                int new_win_h = bw + row_h + 1 + visible_rows * row_h + bw;
                if (new_win_h != win_h) {
                    win_h = new_win_h;
                    XResizeWindow(dpy, win, (unsigned)win_w, (unsigned)win_h);
                }
            }

            if (!done) {
                draw_all(&ctx, xd, gc, win, win_w, win_h, row_h, bw, query, entries,
                         filtered, filtered_count, sel, scroll_off, visible_rows, checked_flags, multi_select);
            }
            break;
        }

        case ButtonRelease: {
            if (ev.xbutton.x < 0 || ev.xbutton.x > win_w || ev.xbutton.y < 0 || ev.xbutton.y > win_h) {
                result.index = -1;
                done = 1;
                break;
            }
            int list_top = bw + row_h + 1;
            if (ev.xbutton.y >= list_top) {
                int row = (ev.xbutton.y - list_top) / row_h;
                int fi = scroll_off + row;
                if (fi >= 0 && fi < filtered_count) {
                    sel = fi;
                    if (multi_select) {
                        checked_flags[filtered[fi]] = !checked_flags[filtered[fi]];
                        draw_all(&ctx, xd, gc, win, win_w, win_h, row_h, bw, query, entries,
                                 filtered, filtered_count, sel, scroll_off, visible_rows, checked_flags, multi_select);
                    } else {
                        result.index = filtered[fi];
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

    XUngrabKeyboard(dpy, CurrentTime);
    XUngrabPointer(dpy, CurrentTime);
    XftDrawDestroy(xd);
    XFreeGC(dpy, gc);
    XDestroyWindow(dpy, win);
    XFlush(dpy);

    free(filtered);
    free(checked_flags);

    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.fg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.bg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.border);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.sel_bg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.sel_fg);
    XftColorFree(dpy, ctx.visual, ctx.cmap, &ctx.disabled_fg);
    XftFontClose(dpy, ctx.font);

    return result;
}
