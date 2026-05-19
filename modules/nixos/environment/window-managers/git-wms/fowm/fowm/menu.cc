#include <string.h>

#include "frame.hh"
#include "menu.hh"
#include "screen.hh"
#include "action.hh"
#include "config.hh"

void menu_window::init()
{
	for (menu_action * act = menu_action::first; act; act = act->next)
	{
		cfg_menu * cfg = &act->menu;
		cfg_style * csp = config::style + STYLE_MENU;

		uint tw = 1;
		uint aw = 0;

		uint n = cfg->nitems;
		for (uint i = 0; i < n; i++)
		{
			const char *s = cfg->items[i].name;
			if (!s)
			{
				s = cfg->items[i].menu->name;
				aw = csp->util.arrow_width;
			}
#ifdef USE_XFT
			XGlyphInfo info;
			XftTextExtentsUtf8(dpy, config::font, str_cast(s), strlen(s), &info);
			uint t = info.xOff;
#else
			uint t = XTextWidth(config::font, s, strlen(s));
#endif
			if (t > tw) tw = t;
		}

		tw += aw + csp->util.left + csp->util.right;

		uint w = tw + csp->left + csp->right;
		uint h = csp->util.height * cfg->nitems + csp->top + csp->bottom;

		XSetWindowAttributes swa;
		swa.event_mask = ButtonPressMask | ButtonReleaseMask | ButtonMotionMask;
		swa.cursor = config::cursor;

		Window win = XCreateWindow(dpy, screen->id(), 0, 0, w, h, 0,
			CopyFromParent, CopyFromParent, nullptr,
			CWEventMask | CWCursor, &swa);

		menu_window * menu = mnew(menu_window, win);

		menu->w_cfg = cfg;
		menu->w_frame = None;
		menu->w_sub_menu = nullptr;
		menu->w_x = 0;
		menu->w_y = 0;
		menu->w_width = w;
		menu->w_height = h;
		menu->w_mapped = false;

		n = cfg->nitems;
		menu->w_num_items = n;
		menu->w_items = n ? menuitem_window::create(n, menu, cfg->items, csp->left, csp->top, tw) : nullptr;

		n = csp->num_borders;
		menu->w_num_decor = n;
		menu->w_decor = n ? udecor_window::create(n, menu, csp->borders, w, h, 0) : nullptr;

		cfg->window = menu;
	}

	menuitem_window::init();
}

int menuitem_window::a_y = 0;

void menuitem_window::init()
{
	cfg_util * cfg = &config::style[STYLE_MENU].util;
	int y = cfg->height - cfg->arrow_height;
	a_y = div2(y);
}

void menu_window::toggle(cfg_menu * cfg, frame_window * frame, int x, int y)
{
	menu_window * win = cfg->window;

	if (win->w_mapped)
	{
		win->close();
	}
	else
	{
		win->w_frame = frame ? frame->id() : None;
		win->open(x, y);
	}
}

void menu_window::close_all()
{
	for (menu_action * act = menu_action::first; act; act = act->next)
	{
		menu_window * win = act->menu.window;
		if (win->w_mapped)
		{
			win->w_sub_menu = nullptr;
			win->close();
		}
	}
}

void menu_window::open(int x, int y)
{
	int mx = screen->width() - w_width;
	int my = screen->height() - w_height;

	if (mx < 0)
	{
		if (x > 0) x = 0;
		else if (x < mx) x = mx;
	}
	else
	{
		if (x < 0) x = 0;
		else if (x > mx) x = mx;
	}

	if (my < 0)
	{
		if (y > 0) y = 0;
		else if (y < my) y = my;
	}
	else
	{
		if (y < 0) y = 0;
		else if (y > my) y = my;
	}

	w_mapped = true;
	w_x = x;
	w_y = y;
	XMoveWindow(dpy, id(), x, y);
	XMapRaised(dpy, id());
}

void menu_window::close()
{
	if (w_sub_menu)
	{
		w_sub_menu->close();
		w_sub_menu = nullptr;
	}

	w_mapped = false;
	XUnmapWindow(dpy, id());
}

static int last_x = 0;
static int last_y = 0;

void menu_window::button_press(XButtonEvent * ev)
{
	last_x = ev->x_root;
	last_y = ev->y_root;
	XRaiseWindow(dpy, id());
}

void menu_window::button_release(XButtonEvent * ev)
{
	if (button_moved) return;
	Window win = ev->subwindow;

	uint n = w_num_items;
	for (uint i = 0; i < n; i++)
	{
		if (w_items[i].id() == win)
		{
			cfg_menu * cfg = w_cfg;
			close_all();

			cfg_menu_item * itm = cfg->items + i;
			if (!itm->name) return;
			itm->act->button_event(ev, screen->find(w_frame));
			return;
		}
	}
}

void menu_window::motion_notify(XMotionEvent * ev)
{
	if (!pressed_button) return;
	button_moved = true;

	int x = w_x;
	int y = w_y;
	int nx = x + ev->x_root - last_x;
	int ny = y + ev->y_root - last_y;

	int mx = screen->width() - w_width;
	int my = screen->height() - w_height;

	if (mx < 0)
	{
		if (nx > 0) nx = 0;
		else if (nx < mx) nx = mx;
	}
	else
	{
		if (nx < 0) nx = 0;
		else if (nx > mx) nx = mx;
	}

	if (my < 0)
	{
		if (ny > 0) ny = 0;
		else if (ny < my) ny = my;
	}
	else
	{
		if (ny < 0) ny = 0;
		else if (ny > my) ny = my;
	}

	last_x += nx - x;
	last_y += ny - y;

	w_x = nx;
	w_y = ny;

	XMoveWindow(dpy, id(), nx, ny);
}

menuitem_window * menuitem_window::create(uint len, menu_window * menu, cfg_menu_item * cfg, int x, int y, uint w)
{
	menuitem_window * ptr = malloc<menuitem_window>(len);
	cfg_style * csp = config::style + STYLE_MENU;
	uint h = csp->util.height;
	int a_x = w - csp->util.arrow_width;

	for (uint i = 0; i < len; i++)
	{
		XSetWindowAttributes swa;
		uint mask = csp->util.pixmap[0] ? CWBackPixmap | CWEventMask : CWBackPixel | CWEventMask;
		swa.background_pixmap = csp->util.pixmap[0];
		swa.background_pixel = csp->util.bg_color[0];
		swa.event_mask = EnterWindowMask | LeaveWindowMask | ExposureMask;

		Window win = XCreateWindow(dpy, menu->id(), x, y, w, h, 0,
			CopyFromParent, CopyFromParent, nullptr, mask, &swa);
		menuitem_window * iwin = new(ptr + i) menuitem_window(win);

		iwin->w_menu = menu;
		iwin->a_x = a_x;
		iwin->a_y = a_y;
		iwin->w_over = false;

		const char * s = cfg[i].name;
		iwin->w_arrow = !s && csp->util.arrow_width;
		if (!s) s = cfg[i].menu->name;

		iwin->w_text = s;
		iwin->w_text_len = strlen(s);

#ifdef USE_XFT
		iwin->w_draw = XftDrawCreate(dpy, win, screen->visual(), screen->colormap());
#else
		XGCValues values;
		values.foreground = csp->util.fg_color[0];
		values.font = config::font->fid;
		iwin->w_gc = XCreateGC(dpy, win, GCForeground | GCFont, &values);
#endif

		XMapWindow(dpy, win);

		y += h;
	}

	return ptr;
}

void menuitem_window::destroy(menuitem_window * ptr, uint len)
{
	for (uint i = 0; i < len; i++)
	{
#ifdef USE_XFT
		XftDrawDestroy(ptr[i].w_draw);
#else
		XFreeGC(dpy, ptr[i].w_gc);
#endif
		XDestroyWindow(dpy, ptr[i].id());
		ptr[i].~menuitem_window();
	}

	free(ptr);
}

void menuitem_window::set_background()
{
	cfg_util * cfg = &config::style[STYLE_MENU].util;
	uint ci = decor_window::color_index(cfg->num_col, w_over);
	decor_window::set_background(id(), cfg->bg_color[ci], cfg->pixmap[ci]);
#ifndef USE_XFT
	XGCValues values;
	values.foreground = cfg->fg_color[ci];
	XChangeGC(dpy, w_gc, GCForeground, &values);
#endif
	expose(nullptr);
}

void menu_window::enter(menuitem_window * item)
{
	if (w_sub_menu)
	{
		w_sub_menu->close();
		w_sub_menu = nullptr;
	}

	long i = item - w_items;
	cfg_menu_item * cfg = w_cfg->items + i;

	if (!cfg->name)
	{
		menu_window * menu = cfg->menu->window;

		int x = w_x + w_width;
		int y = w_y + i * config::style[STYLE_MENU].util.height;

		int mx = screen->width() - menu->w_width;
		if (x > mx)
		{
			x = w_x - menu->w_width;
		}

		w_sub_menu = menu;
		menu->w_frame = w_frame;
		menu->open(x, y);
	}
}

void menuitem_window::enter_notify(XCrossingEvent *)
{
	w_over = true;
	set_background();

	w_menu->enter(this);
}

void menuitem_window::leave_notify(XCrossingEvent *)
{
	w_over = false;
	set_background();
}

#ifdef USE_XFT
void menuitem_window::expose(XExposeEvent * ev)
{
	cfg_util * cfg = &config::style[STYLE_MENU].util;

	if (w_text_len)
	{
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

		uint ci = decor_window::color_index(cfg->num_col, w_over);
		XftDrawStringUtf8(w_draw, cfg->fg_color + ci, config::font, cfg->left, cfg->baseline, str_cast(w_text), w_text_len);
	}

	if (w_arrow)
	{
		int x = a_x;
		int y = a_y;
		int w = cfg->arrow_width;
		int h = cfg->arrow_height;
		if (ev)
		{
			if (ev->x > x) { w -= ev->x - x; x = ev->x; }
			if (ev->y > y) { h -= ev->y - y; y = ev->y; }
			int mw = ev->x + ev->width - x;
			int mh = ev->y + ev->height - y;
			if (w > mw) { w = mw; }
			if (h > mh) { h = mh; }
		}
		if (w > 0 && h > 0)
		{
			XCopyArea(dpy, cfg->arrow[w_over ? 1 : 0], id(), screen->gc(), x - a_x, y - a_y, w, h, x, y);
		}
	}
}
#else
void menuitem_window::expose(XExposeEvent * ev)
{
	if (ev && ev->count) return;

	cfg_util * cfg = &config::style[STYLE_MENU].util;

	if (w_text_len)
	{
		XDrawString(dpy, id(), w_gc, cfg->left, cfg->baseline, w_text, w_text_len);
	}

	if (w_arrow)
	{
		XCopyArea(dpy, cfg->arrow[w_over ? 1 : 0], id(), w_gc, 0, 0,
			cfg->arrow_width, cfg->arrow_height, a_x, a_y);
	}
}
#endif
