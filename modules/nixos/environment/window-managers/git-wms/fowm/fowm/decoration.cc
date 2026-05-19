#include "frame.hh"
#include "config.hh"

Window decor_window::create_window(Window pwin, uint events, rectangle * rect, ulong color, Pixmap pmap)
{
	XSetWindowAttributes swa;
	uint mask = pmap ? CWBackPixmap | CWEventMask : CWBackPixel | CWEventMask;
	swa.background_pixmap = pmap;
	swa.background_pixel = color;
	swa.event_mask = events;

	int x = rect->x;
	int y = rect->y;
	int width = rect->width;
	int height = rect->height;

	if (width < 1)
	{
		x = -1;
		width = 1;
	}

	if (height < 1)
	{
		y = -1;
		height = 1;
	}

	Window win = XCreateWindow(dpy, pwin, x, y, width, height, 0,
		CopyFromParent, CopyFromParent, nullptr, mask, &swa);

	XMapWindow(dpy, win);

	return win;
}

void decor_window::make_rectangle(rectangle * rect, cfg_rect * cfg, uint width, uint height)
{
	int w = width + 1;
	int h = height + 1;

	int x = cfg->left;
	if (x < 0) x += w;
	int y = cfg->top;
	if (y < 0) y += h;

	int x2 = cfg->right;
	if (x2 < 0) x2 += w;
	int y2 = cfg->bottom;
	if (y2 < 0) y2 += h;

	rect->x = x;
	rect->y = y;
	rect->width = x2 > x ? x2 - x : 0;
	rect->height = y2 > y ? y2 - y : 0;
}

void decor_window::set_background(Window id, ulong color, Pixmap pmap)
{
	if (pmap)
	{
		XSetWindowBackgroundPixmap(dpy, id, pmap);
	}
	else
	{
		XSetWindowBackground(dpy, id, color);
	}
	XClearWindow(dpy, id);
}

void decor_window::set_size(Window id, rectangle * rect)
{
	int x = rect->x;
	int y = rect->y;
	int width = rect->width;
	int height = rect->height;

	if (width < 1)
	{
		x = -1;
		width = 1;
	}

	if (height < 1)
	{
		y = -1;
		height = 1;
	}

	XMoveResizeWindow(dpy, id, x, y, width, height);
}

uint decor_window::color_index()
{
	switch (w_num)
	{
	default:
		if (w_press) return 3;
		// fallthrough
	case 3:
		if (w_over) return 2;
		// fallthrough
	case 2:
		if (w_frame->focused()) return 1;
		// fallthrough
	case 1:
	case 0:
		return 0;
	}
}
