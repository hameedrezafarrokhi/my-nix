#include <stdio.h>
#include <unistd.h>

#include "frame.hh"
#include "info.hh"
#include "screen.hh"
#include "config.hh"

bool info_window::is_ws = false;
info_window * info_window::instance = nullptr;

static int make_string(char * str, size_t len, frame_window * fwin)
{
	int w = fwin->width();
	int h = fwin->height();

	cfg_style * cfg = config::style + fwin->style();
	w -= cfg->left + cfg->right;
	h -= cfg->top + cfg->bottom;

	const XSizeHints * hints = fwin->size_hints();
	if (hints->flags & PResizeInc)
	{
		w = (w - hints->base_width) / hints->width_inc;
		h = (h - hints->base_height) / hints->height_inc;
	}

#ifdef USE_XFT
	return snprintf(str, len, "%u\u00D7%u%+d%+d", w, h, fwin->x(), fwin->y());
#else
	return snprintf(str, len, "%u\xD7%u%+d%+d", w, h, fwin->x(), fwin->y());
#endif
}

void info_window::init()
{
	cfg_style * cfg = config::style + STYLE_INFO;

	int w = cfg->util.left + cfg->util.right + 1;
	int h = cfg->util.height;

	int sw = screen->width();
	int sh = screen->height();

	int x = div2(sw - w);
	int y = div2(sh - h);

	XSetWindowAttributes swa;
	uint mask = cfg->util.pixmap[0] ?
		CWBackPixmap | CWEventMask | CWCursor :
		CWBackPixel | CWEventMask | CWCursor;
	swa.background_pixmap = cfg->util.pixmap[0];
	swa.background_pixel = cfg->util.bg_color[0];
	swa.event_mask = EnterWindowMask | LeaveWindowMask | ExposureMask;
	swa.cursor = config::cursor;

	Window win = XCreateWindow(dpy, screen->id(), x, y, w, h, 0,
		CopyFromParent, CopyFromParent, nullptr, mask, &swa);

	info_window * iwin = mnew(info_window, win);
	iwin->w_text_len = 0;
	iwin->w_width = w;

#ifdef USE_XFT
	iwin->w_draw = XftDrawCreate(dpy, win, screen->visual(), screen->colormap());
#else
	XGCValues values;
	values.foreground = cfg->util.fg_color[0];
	values.font = config::font->fid;
	iwin->w_gc = XCreateGC(dpy, win, GCForeground | GCFont, &values);
#endif

	uint n = cfg->num_borders;
	iwin->w_num_decor = n;
	iwin->w_decor = n ? udecor_window::create(n, iwin, cfg->borders, w, h, 0) : nullptr;

	instance = iwin;
}

void info_window::update()
{
#ifdef USE_XFT
	XGlyphInfo info;
	XftTextExtentsUtf8(dpy, config::font, str_cast(w_text), w_text_len, &info);
	int width = info.xOff;
#else
	int width = XTextWidth(config::font, w_text, w_text_len);
#endif

	cfg_style * cfg = config::style + STYLE_INFO;
	int w = cfg->util.left + cfg->util.right + width;

	if (w_width != w)
	{
		int sw = screen->width();
		int sh = screen->height();

		int h = cfg->util.height;
		int x = div2(sw - w);
		int y = div2(sh - h);
		w_width = w;
		XMoveResizeWindow(dpy, id(), x, y, w, h);
		if (w_decor) udecor_window::set_size(w_decor, w_num_decor, cfg->borders, w, h);
	}

	XMapRaised(dpy, id());
	XClearWindow(dpy, id());
	expose(nullptr);
}

void info_window::update_frame(frame_window * fwin)
{
	is_ws = false;
	int len = make_string(w_text, INFO_TEXT_SIZE, fwin);
	if (len < 0 || len > INFO_TEXT_SIZE) len = 0;
	w_text_len = len;
	update();
}

void info_window::update_workspace(uint ws)
{
	is_ws = true;
	int len = snprintf(w_text, INFO_TEXT_SIZE, "Workspace: %u", ws);
	if (len < 0 || len > INFO_TEXT_SIZE) len = 0;
	w_text_len = len;
	alarm(1);
	update();
}

void info_window::unmap()
{
	XUnmapWindow(dpy, id());
}

#ifdef USE_XFT
void info_window::expose(XExposeEvent * ev)
{
	if (!w_text_len) return;

	if (ev)
	{
		XRectangle rect = {};
		rect.x = ev->x;
		rect.y = ev->y;
		rect.width = ev->width;
		rect.height = ev->height;
		XftDrawSetClipRectangles(w_draw, 0, 0, &rect, 1);
	}
	else
	{
		XftDrawSetClip(w_draw, nullptr);
	}

	cfg_util * cfg = &config::style[STYLE_INFO].util;
	XftDrawStringUtf8(w_draw, cfg->fg_color, config::font, cfg->left, cfg->baseline, str_cast(w_text), w_text_len);
}
#else
void info_window::expose(XExposeEvent * ev)
{
	if (ev && ev->count) return;
	if (!w_text_len) return;
	cfg_util * cfg = &config::style[STYLE_INFO].util;
	XDrawString(dpy, id(), w_gc, cfg->left, cfg->baseline, w_text, w_text_len);
}
#endif
