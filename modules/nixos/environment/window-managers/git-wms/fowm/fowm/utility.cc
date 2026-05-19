#include "main.hh"
#include "utility.hh"
#include "config.hh"

udecor_window * udecor_window::create(uint len, window * fwin, cfg_border * cfg, uint w, uint h, uint ci)
{
	udecor_window * ptr = malloc<udecor_window>(len);
	Window pwin = fwin->id();

	for (uint i = 0; i < len; i++)
	{
		rectangle rect;
		decor_window::make_rectangle(&rect, &cfg[i].position, w, h);
		Window win = decor_window::create_window(pwin, NoEventMask,
			&rect, cfg[i].bg_color[ci], cfg[i].pixmap[ci]);
		new(ptr + i) udecor_window(win);
	}

	return ptr;
}

void udecor_window::destroy(udecor_window * ptr, uint len)
{
	for (uint i = 0; i < len; i++)
	{
		XDestroyWindow(dpy, ptr[i].id());
		ptr[i].~udecor_window();
	}
	free(ptr);
}

void udecor_window::set_background(udecor_window * ptr, uint len, cfg_border * cfg, uint ci)
{
	for (uint i = 0; i < len; i++)
	{
		ptr[i].set_background(cfg[i].bg_color[ci], cfg[i].pixmap[ci]);
	}
}

void udecor_window::set_size(udecor_window * ptr, uint len, cfg_border * cfg, uint w, uint h)
{
	for (uint i = 0; i < len; i++)
	{
		rectangle rect;
		decor_window::make_rectangle(&rect, &cfg[i].position, w, h);
		ptr[i].set_size(&rect);
	}
}
