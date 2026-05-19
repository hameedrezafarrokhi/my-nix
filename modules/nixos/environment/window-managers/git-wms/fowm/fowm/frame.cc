#include <string.h>
#include <limits.h>

#include <X11/Xatom.h>

#include "winlist.hh"
#include "winmenu.hh"
#include "atoms.hh"
#include "config.hh"

#define MWM_HINTS_DECORATIONS	2
#define MWM_DECOR_ALL		1
#define MWM_DECOR_BORDER	2
#define MWM_DECOR_TITLE		8

struct MwmHints
{
	ulong flags;
	ulong functions;
	ulong decorations;
};

uchar frame_window::read_mwm_hints(Window win, uchar style)
{
	int format;
	ulong items;
	ulong tmp;
	MwmHints * hints;

	if (XGetWindowProperty(dpy, win, MOTIF_WM_HINTS, 0, 3, False, MOTIF_WM_HINTS,
		&tmp, &format, &items, &tmp, reinterpret_cast<uchar **>(&hints)) == Success)
	{
		if (format == 32 && items >= 3 && hints->flags & MWM_HINTS_DECORATIONS)
		{
			style = STYLE_NONE;

			if (hints->decorations & (MWM_DECOR_ALL | MWM_DECOR_BORDER))
			{
				style |= STYLE_BORDER;
			}

			if (hints->decorations & (MWM_DECOR_ALL | MWM_DECOR_TITLE))
			{
				style |= STYLE_TITLEBAR;
			}
		}

		XFree(hints);
	}

	return style;
}

void frame_window::read_size_hints(Window win, XSizeHints * hints)
{
	long flags = 0;

	long sup;
	if (XGetWMNormalHints(dpy, win, hints, &sup))
		flags = hints->flags;

	if (!(flags & PMinSize))
	{
		hints->min_width = 1;
		hints->min_height = 1;
		flags |= PMinSize;
	}

	if (!(flags & PBaseSize))
	{
		hints->base_width = 0;
		hints->base_height = 0;
		flags |= PBaseSize;
	}

	if (hints->min_width < hints->base_width)
		hints->min_width = hints->base_width;
	if (hints->min_height < hints->base_height)
		hints->min_height = hints->base_height;

	if (flags & PResizeInc)
	{
		if (hints->width_inc < 1 ||
			hints->height_inc < 1)
		{
			flags &= ~PResizeInc;
		}
		else
		{
			int mw = hints->width_inc + hints->base_width;
			int mh = hints->height_inc + hints->base_height;

			if (hints->min_width < mw)
				hints->min_width = mw;
			if (hints->min_height < mh)
				hints->min_height = mh;
		}
	}

	if (flags & PAspect)
	{
		if (hints->min_aspect.x < 1 ||
			hints->min_aspect.y < 1 ||
			hints->max_aspect.x < 1 ||
			hints->max_aspect.y < 1)
		{
			flags &= ~PAspect;
		}
	}

	if (!(flags & PWinGravity))
	{
		hints->win_gravity = NorthWestGravity;
		flags |= PWinGravity;
	}

	hints->flags = flags;
}

static void adjust_position(XSizeHints * hints, cfg_style * cfg)
{
	int x = hints->x;
	int y = hints->y;

	switch (hints->win_gravity)
	{
	case NorthGravity:
		x -= (cfg->left + cfg->right) / 2;
		break;

	case NorthEastGravity:
		x -= cfg->left + cfg->right;
		break;

	case WestGravity:
		y -= (cfg->top + cfg->bottom) / 2;
		break;

	case CenterGravity:
		x -= (cfg->left + cfg->right) / 2;
		y -= (cfg->top + cfg->bottom) / 2;
		break;

	case EastGravity:
		x -= cfg->left + cfg->right;
		y -= (cfg->top + cfg->bottom) / 2;
		break;

	case SouthWestGravity:
		y -= cfg->top + cfg->bottom;
		break;

	case SouthGravity:
		x -= (cfg->left + cfg->right) / 2;
		y -= cfg->top + cfg->bottom;
		break;

	case SouthEastGravity:
		x -= cfg->left + cfg->right;
		y -= cfg->top + cfg->bottom;
		break;

	case StaticGravity:
		x -= cfg->left;
		y -= cfg->top;
		break;
	}

	int min_x = 1 - (hints->width + cfg->left);
	int min_y = 1 - (hints->height + cfg->top);
	int max_x = screen->width() - (cfg->left + 1);
	int max_y = screen->height() - (cfg->top + 1);

	if (x < min_x) x = min_x;
	if (y < min_y) y = min_y;
	if (x > max_x) x = max_x;
	if (y > max_y) y = max_y;

	hints->x = x;
	hints->y = y;
}

static void revert_position(int gravity, int * xp, int * yp, cfg_style * cfg)
{
	int x = *xp;
	int y = *yp;

	switch (gravity)
	{
	case NorthGravity:
		x += (cfg->left + cfg->right) / 2;
		break;

	case NorthEastGravity:
		x += cfg->left + cfg->right;
		break;

	case WestGravity:
		y += (cfg->top + cfg->bottom) / 2;
		break;

	case CenterGravity:
		x += (cfg->left + cfg->right) / 2;
		y += (cfg->top + cfg->bottom) / 2;
		break;

	case EastGravity:
		x += cfg->left + cfg->right;
		y += (cfg->top + cfg->bottom) / 2;
		break;

	case SouthWestGravity:
		y += cfg->top + cfg->bottom;
		break;

	case SouthGravity:
		x += (cfg->left + cfg->right) / 2;
		y += cfg->top + cfg->bottom;
		break;

	case SouthEastGravity:
		x += cfg->left + cfg->right;
		y += cfg->top + cfg->bottom;
		break;

	case StaticGravity:
		x += cfg->left;
		y += cfg->top;
		break;
	}

	*xp = x;
	*yp = y;
}

void frame_window::set_frame_extents(Window win, uchar style)
{
	cfg_style * cfg = config::style + style;
	ulong data[4] = { cfg->left, cfg->right, cfg->top, cfg->bottom };
	XChangeProperty(dpy, win, NET_FRAME_EXTENTS, XA_CARDINAL, 32,
		PropModeReplace, reinterpret_cast<uchar *>(data), 4);
}

static bool is_shaped(Window win)
{
	int shaped = 0;
	union { int i; uint u; } u;

	XShapeQueryExtents(dpy, win, &shaped,
		&u.i, &u.i, &u.u, &u.u,
		&u.i, &u.i, &u.i, &u.u, &u.u);

	return shaped != 0;
}

static bool is_fullscreen(Window win)
{
	Atom type;
	int format;
	ulong items;
	ulong bytes;
	Atom * atoms;
	bool ret = false;

	if (XGetWindowProperty(dpy, win, NET_WM_STATE, 0, INT_MAX, False, XA_ATOM,
		&type, &format, &items, &bytes, reinterpret_cast<uchar **>(&atoms)) == Success)
	{
		if (format == 32 && type == XA_ATOM)
		{
			for (ulong i = 0; i < items; i++)
			{
				if (atoms[i] == NET_WM_STATE_FULLSCREEN)
				{
					ret = true;
					break;
				}
			}
		}

		XFree(atoms);
	}

	return ret;
}

frame_window * frame_window::create(Window cwin, bool restore, int x, int y, uint cw, uint ch)
{
	bool shaped = is_shaped(cwin);

	XSizeHints * hints = XAllocSizeHints();
	read_size_hints(cwin, hints);

	uchar style = read_mwm_hints(cwin, shaped ? STYLE_NO_BORDER : STYLE_NORMAL);
	cfg_style * cfg = config::style + style;

	if (hints->flags & (USPosition | PPosition))
	{
		hints->x = x;
		hints->y = y;
		hints->width = cw;
		hints->height = ch;
		adjust_position(hints, cfg);
		x = hints->x;
		y = hints->y;
	}
	else if (!restore)
	{
		int w = cw + cfg->left + cfg->right;
		int h = ch + cfg->top + cfg->bottom;
		int sw = screen->width();
		int sh = screen->height();
		x = div2(sw - w);
		y = div2(sh - h);
	}

	bool fullscreen = is_fullscreen(cwin);
	int fx, fy;
	uint fw, fh;

	if (fullscreen)
	{
		fx = 0;
		fy = 0;
		fw = screen->width();
		fh = screen->height();
	}
	else
	{
		fx = x;
		fy = y;
		fw = cw + cfg->left + cfg->right;
		fh = ch + cfg->top + cfg->bottom;
	}

	XSetWindowAttributes swa;
	swa.event_mask = ButtonPressMask | ButtonReleaseMask |
		EnterWindowMask | LeaveWindowMask |
		SubstructureRedirectMask | StructureNotifyMask;
	swa.cursor = config::cursor;

	Window fwin = XCreateWindow(dpy, screen->id(), fx, fy, fw, fh, 0,
		CopyFromParent, CopyFromParent, nullptr,
		CWEventMask | CWCursor, &swa);

	frame_window * frame = mnew(frame_window, fwin, cwin);
	frame->w_hints = hints;
	frame->w_x = fx;
	frame->w_y = fy;
	frame->w_width = fw;
	frame->w_height = fh;
	frame->saved_x = x;
	frame->saved_y = y;
	frame->saved_width = cw;
	frame->saved_height = ch;
	frame->saved_style = style;
	frame->w_shade = 0;
	frame->w_max = 0;
	frame->w_focused = false;
	frame->w_mapped = false;
	frame->w_shaped = shaped;
	frame->w_fullscreen = fullscreen;
	frame->w_workspace = screen->workspace();

	if (fullscreen)
	{
		style = STYLE_NONE;
		cfg = config::style;
	}
	frame->w_style = style;

	frame->fetch_name();
	frame->w_title = (style & STYLE_TITLEBAR) ? title_window::create(frame) : nullptr;
	uint n = cfg->num_borders;
	frame->w_num_borders = n;
	frame->w_borders = n ? border_window::create(n, frame) : nullptr;

	XAddToSaveSet(dpy, cwin);
	XSetWindowBorderWidth(dpy, cwin, 0);
	XReparentWindow(dpy, cwin, fwin, cfg->left, cfg->top);
	if (fullscreen) XResizeWindow(dpy, cwin, fw, fh);
	XLowerWindow(dpy, cwin);
	XSelectInput(dpy, cwin, FocusChangeMask | PropertyChangeMask | StructureNotifyMask);

	if (shaped)
	{
		XShapeSelectInput(dpy, cwin, ShapeNotifyMask);
		frame->set_shape();
	}

	if (config::modifier)
	{
		XGrabButton(dpy, AnyButton, config::modifier, cwin, False,
			ButtonPressMask | ButtonReleaseMask | ButtonMotionMask,
			GrabModeAsync, GrabModeAsync, None, None);
	}

	set_frame_extents(cwin, style);

	frame->read_wm_protos();
	int state = frame->read_wm_hints();

	frame->w_iconified = state == IconicState;
	frame->w_hidden = state == IconicState;
	if (state != IconicState)
	{
		XMapWindow(dpy, cwin);
		XMapWindow(dpy, fwin);
	}
	frame->set_state(state != IconicState ? NormalState : IconicState);

	screen->frame_list.add(frame);

	frame->send_configure_notify();

	return frame;
}

void frame_window::destroy()
{
	if (screen->focus == this) screen->focus = nullptr;
	screen->frame_list.remove(this);
	winmenu_action::clean = false;

	int x = w_x;
	int y = w_y;
	if (w_hints->flags & (USPosition | PPosition))
	{
		cfg_style * cfg = config::style + w_style;
		revert_position(w_hints->win_gravity, &x, &y, cfg);
	}

	Window cwin = client.id();
	XUngrabButton(dpy, AnyButton, AnyModifier, cwin);
	if (w_shaped) XShapeSelectInput(dpy, cwin, NoEventMask);
	XSelectInput(dpy, cwin, NoEventMask);
	XReparentWindow(dpy, cwin, screen->id(), x, y);
	XRemoveFromSaveSet(dpy, cwin);
	XDeleteProperty(dpy, cwin, WM_STATE);
	XDeleteProperty(dpy, cwin, NET_FRAME_EXTENTS);

	if (w_borders) border_window::destroy(w_borders, w_num_borders);
	if (w_title) w_title->destroy();
	if (w_name) free(w_name);
	XFree(w_hints);

	XDestroyWindow(dpy, id());
	mdelete(frame_window, this);
}

int frame_window::read_wm_hints()
{
	int state = NormalState;
	w_input = true;

	XWMHints * hints = XGetWMHints(dpy, client.id());
	if (hints)
	{
		long flags = hints->flags;
		if (flags & InputHint)
			w_input = hints->input;
		if (flags & StateHint)
			state = hints->initial_state;
		XFree(hints);
	}

	return state;
}

void frame_window::read_wm_protos()
{
	Atom * atoms;
	int count;

	w_delete_window = false;
	w_take_focus = false;

	if (XGetWMProtocols(dpy, client.id(), &atoms, &count))
	{
		for (int i = 0; i < count; i++)
		{
			Atom atom = atoms[i];
			if (atom == WM_DELETE_WINDOW)
				w_delete_window = true;
			if (atom == WM_TAKE_FOCUS)
				w_take_focus = true;
		}

		XFree(atoms);
	}
}

void frame_window::set_shape()
{
	XRectangle rect = {};
	rect.width = w_width;
	rect.height = w_height;

	XShapeCombineRectangles(dpy, id(), ShapeBounding, 0, 0, &rect, 1, ShapeSet, YXBanded);

	if (w_shade) return;

	cfg_style * cfg = config::style + w_style;
	int x = cfg->left;
	int y = cfg->top;

	rect.width -= (cfg->left + cfg->right);
	rect.height -= (cfg->top + cfg->bottom);
	XShapeCombineRectangles(dpy, id(), ShapeBounding, x, y, &rect, 1, ShapeSubtract, YXBanded);

	XShapeCombineShape(dpy, id(), ShapeBounding, x, y, client.id(), ShapeBounding, ShapeUnion);
}

void frame_window::set_state(ulong state)
{
	ulong data[2] = { state, None };
	XChangeProperty(dpy, client.id(), WM_STATE, WM_STATE, 32, PropModeReplace, reinterpret_cast<uchar *>(data), 2);
}

void frame_window::deiconify()
{
	w_iconified = false;
	if (w_workspace && w_workspace != screen->workspace())
		return;
	if (w_hidden) map();
}

void frame_window::map()
{
	w_hidden = false;
	XMapWindow(dpy, client.id());
	XMapWindow(dpy, id());
	set_state(NormalState);
}

void frame_window::iconify()
{
	w_iconified = true;
	if (!w_hidden) unmap();
}

void frame_window::unmap()
{
	w_hidden = true;
	XUnmapWindow(dpy, id());
	XUnmapWindow(dpy, client.id());
	set_state(IconicState);
}

void frame_window::show()
{
	raise();
	deiconify();

	if (w_workspace && w_workspace != screen->workspace())
	{
		screen->set_workspace(w_workspace);
	}
}

void frame_window::set_workspace(uint ws)
{
	if (ws < 1) ws = config::workspaces;
	if (ws > config::workspaces) ws = 1;

	if (ws == w_workspace) return;
	w_workspace = ws;

	if (ws == screen->workspace())
	{
		if (!w_iconified) map();
	}
	else
	{
		if (!w_hidden) unmap();
	}
}

void frame_window::set_sticky(bool stick)
{
	if (stick)
	{
		w_workspace = 0;
		if (!w_iconified && w_hidden) map();
	}
	else if (!w_workspace)
	{
		w_workspace = screen->workspace();
	}
}

void frame_window::set_style(uchar style)
{
	if (w_style == style) return;

	cfg_style * cfg = config::style + w_style;
	uint w = w_width - (cfg->left + cfg->right);
	uint h = w_height - (cfg->top + cfg->bottom);

	cfg = config::style + style;
	uint x = cfg->left;
	uint y = cfg->top;
	w += x + cfg->right;
	h += y + cfg->bottom;

	if (h == 0)
	{
		h += w_shade;
		w_shade = 0;
	}

	w_width = w;
	w_height = h;
	w_style = style;

	XMoveWindow(dpy, client.id(), x, y);
	XResizeWindow(dpy, id(), w, h);

	if (w_borders) border_window::destroy(w_borders, w_num_borders);
	if (w_title) w_title->destroy();

	w_title = (style & STYLE_TITLEBAR) ? title_window::create(this) : nullptr;
	uint n = cfg->num_borders;
	w_num_borders = n;
	w_borders = n ? border_window::create(n, this) : nullptr;
	if (w_shaped) set_shape();

	set_frame_extents(client.id(), style);
	check();
}

#ifdef USE_XFT
static bool get_string_property(Window win, Atom type, char ** value, uint * len)
{
	XTextProperty prop;
	ulong bytes;
	bool ret = false;

	if (XGetWindowProperty(dpy, win, type, 0, INT_MAX, False, AnyPropertyType,
		&prop.encoding, &prop.format, &prop.nitems, &bytes, &prop.value) == Success)
	{
		if (prop.format == 8 && prop.encoding == UTF8_STRING)
		{
			size_t size = prop.nitems;
			char * name = malloc<char>(size + 1);
			memcpy(name, prop.value, size + 1);
			*value = name;
			*len = size;
			ret = true;
		}
		else
		{
			char ** list = nullptr;
			int count = 0;

			Xutf8TextPropertyToTextList(dpy, &prop, &list, &count);
			if (list)
			{
				if (count > 0)
				{
					size_t size = strlen(list[0]);
					char * name = malloc<char>(size + 1);
					memcpy(name, list[0], size + 1);
					*value = name;
					*len = size;
					ret = true;
				}
				XFreeStringList(list);
			}
		}
		XFree(prop.value);
	}

	return ret;
}
#else
static size_t utf8_size(uchar * str, size_t len)
{
	size_t l = 1;
	for (size_t i = 0; i < len; i++)
	{
		uchar c = str[i];
		if (c < 0x80 || c >= 0xC0) l++;
	}
	return l;
}

static size_t utf8_to_string(char * dst, uchar * src, size_t len)
{
	size_t l = 0;
	uint n = 0;
	uint cp;

	for (size_t i = 0; i < len; i++)
	{
		uchar c = src[i];

		if (c < 0x80)
		{
			dst[l++] = c;
		}
		else if (c < 0xC0)
		{
			if (!n) continue;
			cp = (cp << 6) | (c & 0x3F);
			if (--n) continue;
			dst[l++] = (cp < 0x100) ? cp : 0x7F;
		}
		else if (c < 0xE0)
		{
			cp = c & 0x1F;
			n = 1;
		}
		else if (c < 0xF0)
		{
			cp = c & 0xF;
			n = 2;
		}
		else if (c < 0xF8)
		{
			cp = c & 0x7;
			n = 3;
		}
		else if (c < 0xFC)
		{
			cp = c & 0x3;
			n = 4;
		}
		else if (c < 0xFE)
		{
			cp = c & 0x1;
			n = 5;
		}
	}

	dst[l] = 0;
	return l;
}

static bool get_string_property(Window win, Atom prop, char ** value, uint * len)
{
	Atom type;
	int format;
	ulong items;
	ulong bytes;
	uchar * str;
	bool ret = false;

	if (XGetWindowProperty(dpy, win, prop, 0, INT_MAX, False, AnyPropertyType,
		&type, &format, &items, &bytes, &str) == Success)
	{
		if (format == 8)
		{
			if (type == XA_STRING)
			{
				char * name = malloc<char>(items + 1);
				memcpy(name, str, items + 1);
				*value = name;
				*len = items;
				ret = true;
			}
			else if (type == UTF8_STRING)
			{
				char * name = malloc<char>(utf8_size(str, items));
				size_t size = utf8_to_string(name, str, items);
				*value = name;
				*len = size;
				ret = true;
			}
		}
		XFree(str);
	}

	return ret;
}
#endif

void frame_window::fetch_name()
{
	winmenu_action::clean = false;

	if (get_string_property(client.id(), NET_WM_NAME, &w_name, &w_name_len))
	{
		w_ewmh_name = true;
		return;
	}

	if (get_string_property(client.id(), XA_WM_NAME, &w_name, &w_name_len))
	{
		w_ewmh_name = false;
		return;
	}

	w_name = NULL;
	w_name_len = 0;
	w_ewmh_name = false;
}

void frame_window::set_title()
{
	if (w_name) free(w_name);
	fetch_name();
	if (w_title) w_title->set_title();
}

void frame_window::send_message(Atom atom)
{
	Window cwin = client.id();
	XEvent ev = {};
	ev.xclient.type = ClientMessage;
	ev.xclient.window = cwin;
	ev.xclient.message_type = WM_PROTOCOLS;
	ev.xclient.format = 32;
	ev.xclient.data.l[0] = atom;
	ev.xclient.data.l[1] = timestamp;
	XSendEvent(dpy, cwin, False, NoEventMask, &ev);
}

void frame_window::focus()
{
	if (w_input) XSetInputFocus(dpy, client.id(), RevertToPointerRoot, timestamp);
	if (w_take_focus) send_message(WM_TAKE_FOCUS);
}

void frame_window::close()
{
	if (w_delete_window)
		send_message(WM_DELETE_WINDOW);
	else
		kill();
}

void frame_window::check()
{
	int x = w_x;
	int y = w_y;

	cfg_style * cfg = config::style + w_style;
	int min_x = (cfg->right + 1) - w_width;
	int min_y = (cfg->bottom + 1) - w_height;
	int max_x = screen->width() - (cfg->left + 1);
	int max_y = screen->height() - (cfg->top + 1);

	if (x < min_x) x = min_x;
	if (y < min_y) y = min_y;
	if (x > max_x) x = max_x;
	if (y > max_y) y = max_y;

	if (x == w_x && y == w_y) return;

	w_x = x;
	w_y = y;
	XMoveWindow(dpy, id(), x, y);
	send_configure_notify();
}

void frame_window::check_snap(int * x, int * y)
{
	int d1 = config::snap_dist[2];
	int d2 = config::snap_dist[3];

	int x1 = *x;
	int y1 = *y;
	int x2 = x1 + w_width;
	int y2 = y1 + w_height;

	if (d1 || d2) for (frame_window * win =
		screen->frame_list.first(); win; win = win->next())
	{
		if (win == this) continue;

		int x3 = win->w_x;
		int y3 = win->w_y;
		int x4 = x3 + win->w_width;
		int y4 = y3 + win->w_height;

		if (x1 < x4 && x2 > x3)
		{
			if (y2 > y3 - d1 && y2 < y3 + d2)
			{
				*y = y3 - w_height;
				continue;
			}

			if (y1 > y4 - d2 && y1 < y4 + d1)
			{
				*y = y4;
				continue;
			}
		}

		if (y1 < y4 && y2 > y3)
		{
			if (x2 > x3 - d1 && x2 < x3 + d2)
			{
				*x = x3 - w_width;
				continue;
			}

			if (x1 > x4 - d2 && x1 < x4 + d1)
			{
				*x = x4;
				continue;
			}
		}
	}

	d1 = config::snap_dist[0];
	d2 = config::snap_dist[1];
	int d3 = config::snap_dist[4];

	if (!(d1 || d2 || d3)) return;

	int sw = screen->width();
	int sh = screen->height();

	if (x1 > -d2 && x1 < d1)
	{
		*x = 0;
	}
	else if (x2 > sw - d1 && x2 < sw + d2)
	{
		*x = sw - w_width;
	}
	else if (d3)
	{
		int w = w_width;
		int x3 = div2(sw - w);

		if (x1 > x3 - d3 && x1 < x3 + d3)
			*x = x3;
	}

	if (y1 > -d2 && y1 < d1)
	{
		*y = 0;
	}
	else if (y2 > sh - d1 && y2 < sh + d2)
	{
		*y = sh - w_height;
	}
	else if (d3)
	{
		int h = w_height;
		int y3 = div2(sh - h);

		if (y1 > y3 - d3 && y1 < y3 + d3)
			*y = y3;
	}
}

void frame_window::move(int x, int y)
{
	cfg_style * cfg = config::style + w_style;
	int min_x = (cfg->right + 1) - w_width;
	int min_y = (cfg->bottom + 1) - w_height;
	int max_x = screen->width() - (cfg->left + 1);
	int max_y = screen->height() - (cfg->top + 1);

	if (x < min_x) x = min_x;
	if (y < min_y) y = min_y;
	if (x > max_x) x = max_x;
	if (y > max_y) y = max_y;

	if (x == w_x && y == w_y)
		return;

	w_x = x;
	w_y = y;
	XMoveWindow(dpy, id(), x, y);
	send_configure_notify();
}

void frame_window::resize(int grav, int x, int y, uint width, uint height)
{
	cfg_style * cfg = config::style + w_style;
	uint bx = cfg->left + cfg->right;
	uint by = cfg->top + cfg->bottom;

	long flags = w_hints->flags;
	int w = width - bx;
	int h = height - by;

	if (flags & PAspect)
	{
		long base_w = w_hints->base_width;
		long base_h = w_hints->base_height;

		long aw = w - base_w;
		long ah = h - base_h;

		long min_ax = w_hints->min_aspect.x;
		long min_ay = w_hints->min_aspect.y;
		long max_ax = w_hints->max_aspect.x;
		long max_ay = w_hints->max_aspect.y;

		if (aw * min_ay < ah * min_ax)
		{
			long n = aw * min_ay + ah * min_ax;
			long m = min_ax * min_ay * 2;

			aw = min_ax * n / m;
			ah = min_ay * n / m;
		}
		else if (aw * max_ay > ah * max_ax)
		{
			long n = aw * max_ay + ah * max_ax;
			long m = max_ax * max_ay * 2;

			aw = max_ax * n / m;
			ah = max_ay * n / m;
		}

		w = aw + base_w;
		h = ah + base_h;
	}

	if (flags & PMinSize)
	{
		if (w < w_hints->min_width)
			w = w_hints->min_width;
		if (h < w_hints->min_height)
			h = w_hints->min_height;
	}

	if (flags & PMaxSize)
	{
		if (w > w_hints->max_width)
			w = w_hints->max_width;
		if (h > w_hints->max_height)
			h = w_hints->max_height;
	}

	if (flags & PResizeInc)
	{
		int w_inc = w_hints->width_inc;
		int h_inc = w_hints->height_inc;
		int base_w = w_hints->base_width;
		int base_h = w_hints->base_height;

		w = (((w - base_w) / w_inc) * w_inc) + base_w;
		h = (((h - base_h) / h_inc) * h_inc) + base_h;
	}

	uint nw = w + bx;
	uint nh = h + by;

	if (nw == w_width && nh == (w_height + w_shade))
		return;

	switch(grav)
	{
	case NorthEastGravity:
		if (nw != width) x += width - nw;
		break;
	case SouthWestGravity:
		if (nh != height) y += height - nh;
		break;
	case SouthEastGravity:
		if (nw != width) x += width - nw;
		if (nh != height) y += height - nh;
		break;
	}

	int min_x = 1 - (w + cfg->left);
	if (x < min_x) return;

	int min_y = 1 - (h + cfg->top);
	if (y < min_y) return;

	int max_x = screen->width() - (cfg->left + 1);
	if (x > max_x) return;

	int max_y = screen->height() - (cfg->top + 1);
	if (y > max_y) return;

	w_x = x;
	w_y = y;
	w_width = nw;
	w_height = nh;
	w_shade = 0;
	w_max = 0;
	XMoveResizeWindow(dpy, id(), x, y, nw, nh);
	XResizeWindow(dpy, client.id(), w, h);
	if (w_title) w_title->set_size();
	border_window::set_size(w_borders, w_num_borders, cfg->borders, nw, nh);
	if (w_shaped) set_shape();
	send_configure_notify();
}

void frame_window::maximize(uchar max)
{
	cfg_style * cfg = config::style + w_style;
	int bx = cfg->left + cfg->right;
	int by = cfg->top + cfg->bottom;

	int x = w_x;
	int y = w_y;
	int w = w_width - bx;
	int h = w_height + w_shade - by;

	if (w_fullscreen)
	{
		if (max & MAXIMIZE_H)
		{
			x = 0;
			w = screen->width() - bx;
		}

		if (max & MAXIMIZE_V)
		{
			y = 0;
			h = screen->height() - by;
		}
	}
	else
	{
		uchar m = w_max & max;
		if (m)
		{
			if (m & MAXIMIZE_H)
			{
				x = saved_x;
				w = saved_width;
			}

			if (m & MAXIMIZE_V)
			{
				y = saved_y;
				h = saved_height;
			}

			w_max &= ~max;
		}
		else
		{
			if (max & MAXIMIZE_H)
			{
				saved_x = x;
				saved_width = w;

				x = 0;
				w = screen->width() - bx;
			}

			if (max & MAXIMIZE_V)
			{
				saved_y = y;
				saved_height = h;

				y = 0;
				h = screen->height() - by;
			}

			w_max |= max;
		}
	}

	long flags = w_hints->flags;

	if (flags & PMinSize)
	{
		if (w < w_hints->min_width)
			w = w_hints->min_width;
		if (h < w_hints->min_height)
			h = w_hints->min_height;
	}

	if (flags & PMaxSize)
	{
		if (w > w_hints->max_width)
			w = w_hints->max_width;
		if (h > w_hints->max_height)
			h = w_hints->max_height;
	}

	if (flags & PResizeInc)
	{
		int w_inc = w_hints->width_inc;
		int h_inc = w_hints->height_inc;
		int base_w = w_hints->base_width;
		int base_h = w_hints->base_height;

		w = (((w - base_w) / w_inc) * w_inc) + base_w;
		h = (((h - base_h) / h_inc) * h_inc) + base_h;
	}

	uint ow = w;
	uint oh = h;

	uint nw = ow + bx;
	uint nh = oh + by;

	w_x = x;
	w_y = y;
	w_width = nw;
	w_height = nh;
	w_shade = 0;
	XMoveResizeWindow(dpy, id(), x, y, nw, nh);
	XResizeWindow(dpy, client.id(), ow, oh);
	if (w_title) w_title->set_size();
	border_window::set_size(w_borders, w_num_borders, cfg->borders, nw, nh);
	if (w_shaped) set_shape();
	send_configure_notify();
}

void frame_window::shade(bool set)
{
	cfg_style * cfg = config::style + w_style;
	uint h = w_height;
	uint s = w_shade;

	if (set)
	{
		if (s) return;

		uint y = cfg->top + cfg->bottom;
		if (y == 0) return;

		s = h - y;
		h = y;
	}
	else
	{
		if (s == 0) return;

		h += s;
		s = 0;
	}

	w_height = h;
	w_shade = s;
	uint w = w_width;

	XResizeWindow(dpy, id(), w, h);
	if (w_title) w_title->set_size();
	border_window::set_size(w_borders, w_num_borders, cfg->borders, w, h);
	if (w_shaped) set_shape();
	check();
}

void frame_window::set_fullscreen(bool set)
{
	bool f = w_fullscreen;
	uchar style;
	int fx, fy;
	uint cw, ch;

	if (set)
	{
		if (f) return;

		cfg_style * cfg = config::style + w_style;
		saved_x = w_x;
		saved_y = w_y;
		saved_width = w_width - (cfg->left + cfg->right);
		saved_height = (w_height + w_shade) - (cfg->top + cfg->bottom);
		saved_style = w_style;

		style = STYLE_NONE;
		fx = 0;
		fy = 0;
		cw = screen->width();
		ch = screen->height();
	}
	else
	{
		if (!f) return;
		style = saved_style;
		fx = saved_x;
		fy = saved_y;
		cw = saved_width;
		ch = saved_height;
	}

	cfg_style * cfg = config::style + style;
	uint cx = cfg->left;
	uint cy = cfg->top;
	uint fw = cw + cx + cfg->right;
	uint fh = ch + cy + cfg->bottom;

	w_x = fx;
	w_y = fy;
	w_width = fw;
	w_height = fh;
	w_shade = 0;
	w_max = 0;
	w_style = style;
	w_fullscreen = set;

	XMoveResizeWindow(dpy, id(), fx, fy, fw, fh);
	XMoveResizeWindow(dpy, client.id(), cx, cy, cw, ch);

	if (w_borders) border_window::destroy(w_borders, w_num_borders);
	if (w_title) w_title->destroy();

	w_title = (style & STYLE_TITLEBAR) ? title_window::create(this) : nullptr;
	uint n = cfg->num_borders;
	w_num_borders = n;
	w_borders = n ? border_window::create(n, this) : nullptr;
	if (w_shaped) set_shape();

	set_frame_extents(client.id(), style);
	XChangeProperty(dpy, client.id(), NET_WM_STATE, XA_ATOM, 32, PropModeReplace,
		reinterpret_cast<uchar *>(&NET_WM_STATE_FULLSCREEN), set ? 1 : 0);
	send_configure_notify();
}

void frame_window::send_configure_notify()
{
	cfg_style * cfg = config::style + w_style;
	int x = w_x;
	int y = w_y;
	uint w = w_width - (cfg->left + cfg->right);
	uint h = (w_height + w_shade) - (cfg->top + cfg->bottom);

	revert_position(w_hints->win_gravity, &x, &y, cfg);

	Window cwin = client.id();
	XEvent xev = {};
	xev.xconfigure.type = ConfigureNotify;
	xev.xconfigure.event = cwin;
	xev.xconfigure.window = cwin;
	xev.xconfigure.x = x;
	xev.xconfigure.y = y;
	xev.xconfigure.width = w;
	xev.xconfigure.height = h;
	XSendEvent(dpy, cwin, False, StructureNotifyMask, &xev);
}

void frame_window::enter_notify(XCrossingEvent *)
{
	screen->focus = this;
	focus();
}

void frame_window::leave_notify(XCrossingEvent *)
{
	if (screen->focus == this)
		screen->focus = nullptr;
}

void frame_window::unmap_notify(XUnmapEvent *)
{
	w_mapped = false;
}

void frame_window::map_notify(XMapEvent *)
{
	w_mapped = true;
}

void frame_window::map_request(XMapRequestEvent * ev)
{
	if (ev->window == client.id())
		deiconify();
}

void frame_window::configure_request(XConfigureRequestEvent * ev)
{
	if (ev->window != client.id()) return;

	cfg_style * cfg = config::style + w_style;
	ulong mask = ev->value_mask;

	uint bx = cfg->left + cfg->right;
	uint by = cfg->top + cfg->bottom;
	uint w = w_width - bx;
	uint h = w_height + w_shade - by;

	if (mask & (CWX | CWY))
	{
		XSizeHints * hints = w_hints;
		hints->x = ev->x;
		hints->y = ev->y;
		hints->width = (mask & CWWidth) ? ev->width : w;
		hints->height = (mask & CWHeight) ? ev->height : h;
		adjust_position(hints, cfg);
		if (mask & CWX) w_x = hints->x;
		if (mask & CWY) w_y = hints->y;
		XMoveWindow(dpy, id(), w_x, w_y);
	}

	if (mask & (CWWidth | CWHeight))
	{
		if (mask & CWWidth) w = ev->width;
		if (mask & CWHeight) h = ev->height;

		uint fw = w + bx;
		uint fh = h + by;

		w_width = fw;
		w_height = fh;
		w_shade = 0;
		w_max = 0;
		XResizeWindow(dpy, id(), fw, fh);
		XResizeWindow(dpy, client.id(), w, h);
		if (w_title) w_title->set_size();
		border_window::set_size(w_borders, w_num_borders, cfg->borders, fw, fh);
		if (w_shaped) set_shape();
	}

	send_configure_notify();
}

void frame_window::xclient_message(XClientMessageEvent * ev)
{
	if (ev->message_type == NET_REQUEST_FRAME_EXTENTS)
	{
		Window win = ev->window;
		bool shaped = is_shaped(win);
		uchar style = read_mwm_hints(win, shaped ? STYLE_NO_BORDER : STYLE_NORMAL);
		set_frame_extents(win, style);
	}
}
