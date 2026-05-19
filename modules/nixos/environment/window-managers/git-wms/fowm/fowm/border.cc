#include "frame.hh"
#include "decorfunc.hh"
#include "config.hh"

border_window * border_window::create(uint len, frame_window * fwin)
{
	border_window * ptr = malloc<border_window>(len);
	bool f = fwin->focused();
	Window pwin = fwin->id();
	uint width = fwin->width();
	uint height = fwin->height();
	cfg_border * cfg = config::style[fwin->style()].borders;

	for (uint i = 0; i < len; i++)
	{
		rectangle rect;
		decor_window::make_rectangle(&rect, &cfg[i].position, width, height);
		uint ci = decor_window::color_index(cfg[i].num_col, f);
		Window win = decor_window::create_window(pwin,
			ButtonPressMask | ButtonReleaseMask | ButtonMotionMask |
			EnterWindowMask | LeaveWindowMask,
			&rect, cfg[i].bg_color[ci], cfg[i].pixmap[ci]);
		new(ptr + i) border_window(win, fwin, i, cfg[i].act_idx, cfg[i].num_col, 0);
	}

	return ptr;
}

void border_window::destroy(border_window * ptr, uint len)
{
	for (uint i = 0; i < len; i++)
	{
		XDestroyWindow(dpy, ptr[i].id());
		ptr[i].~border_window();
	}
	free(ptr);
}

void border_window::set_size(border_window * ptr, uint len, cfg_border * cfg, uint w, uint h)
{
	for (uint i = 0; i < len; i++)
	{
		rectangle rect;
		decor_window::make_rectangle(&rect, &cfg[i].position, w, h);
		ptr[i].set_size(&rect);
	}
}

void border_window::set_background(border_window * ptr, uint len, uint style)
{
	cfg_border * cfg = config::style[style].borders;
	for (uint i = 0; i < len; i++)
	{
		uint ci = ptr[i].color_index();
		ptr[i].set_background(cfg[i].bg_color[ci], cfg[i].pixmap[ci]);
	}
}

void border_window::set_background()
{
	cfg_border * cfg = config::style[frame()->style()].borders + index();
	uint ci = color_index();
	set_background(cfg->bg_color[ci], cfg->pixmap[ci]);
}
