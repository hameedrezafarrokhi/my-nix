#include <X11/Xatom.h>

#include "frame.hh"
#include "screen.hh"
#include "info.hh"
#include "action.hh"
#include "atoms.hh"
#include "config.hh"
#include "menu.hh"

root_window * root_window::create(int scr)
{
	root_window * root = mnew(root_window, scr);
	Screen * scrn = ScreenOfDisplay(dpy, scr);

	root->s_width = WidthOfScreen(scrn);
	root->s_height = HeightOfScreen(scrn);
	root->s_colormap = DefaultColormapOfScreen(scrn);
	root->s_workspace = 1;
#ifdef USE_XFT
	root->s_number = scr;
	root->s_visual = DefaultVisualOfScreen(scrn);
	root->s_gc = DefaultGCOfScreen(scrn);
#endif
	root->focus = nullptr;

	Window win = root->id();
	XSelectInput(dpy, win,
		KeyPressMask |
		ButtonPressMask |
		ButtonReleaseMask |
		SubstructureRedirectMask |
		StructureNotifyMask);

	XChangeProperty(dpy, win, NET_SUPPORTED, XA_ATOM, 32, PropModeReplace,
		reinterpret_cast<uchar *>(atoms::atom + atoms::net_supported),
		atoms::NUM_ATOMS - atoms::net_supported);

	return root;
}

void root_window::destroy()
{
	XUngrabKey(dpy, AnyKey, AnyModifier, id());
	XSelectInput(dpy, id(), 0);

	while (frame_window * win = frame_list.first())
	{
		if (win->hidden()) win->map();
		win->destroy();
	}

	XDeleteProperty(dpy, id(), NET_SUPPORTING_WM_CHECK);
	XDeleteProperty(dpy, id(), NET_SUPPORTED);
	mdelete(root_window, this);
}

void root_window::init()
{
	Window info = info_window::get_id();
	XChangeProperty(dpy, info, NET_SUPPORTING_WM_CHECK, XA_WINDOW, 32,
		PropModeReplace, reinterpret_cast<uchar *>(&info), 1);
	XChangeProperty(dpy, info, NET_WM_NAME, UTF8_STRING, 8,
		PropModeReplace, reinterpret_cast<const uchar *>("fowm"), 4);
	XChangeProperty(dpy, id(), NET_SUPPORTING_WM_CHECK, XA_WINDOW, 32,
		PropModeReplace, reinterpret_cast<uchar *>(&info), 1);

	Window rootwid;
	Window parent;
	Window * children;
	uint nchildren;

	if (XQueryTree(dpy, id(), &rootwid, &parent, &children, &nchildren))
	{
		for (uint i = 0; i < nchildren; i++)
		{
			XWindowAttributes wa;
			if (XGetWindowAttributes(dpy, children[i], &wa) &&
				wa.map_state != IsUnmapped &&
				!wa.override_redirect)
			{
				frame_window::create(children[i], true,
					wa.x, wa.y, wa.width, wa.height);
			}
		}

		XFree(children);
	}

	uint n = config::num_keys;
	for (uint i = 0; i < n; i++)
	{
		cfg_key * cfg = config::keys + i;
		XGrabKey(dpy, cfg->key, cfg->mod, id(), True, GrabModeAsync, GrabModeAsync);
	}
}

void root_window::set_workspace(uint ws)
{
	if (ws < 1) ws = config::workspaces;
	if (ws > config::workspaces) ws = 1;

	if (ws == s_workspace) return;

	menu_window::close_all();

	s_workspace = ws;

	for (frame_window * win = frame_list.first(); win; win = win->next())
	{
		uint w = win->workspace();
		if (!w) continue;
		if (w == ws)
		{
			if (!win->iconified()) win->map();
		}
		else
		{
			if (!win->hidden()) win->unmap();
		}
	}

	info_window::set_workspace(ws);
}

frame_window * root_window::find(Window id)
{
	if (!id) return nullptr;

	for (frame_window * win = frame_list.first(); win; win = win->next())
	{
		if (win->id() == id)
			return win;
	}

	return nullptr;
}

void root_window::key_press(XKeyEvent * ev)
{
	uint mod = ev->state;
	uint key = ev->keycode;

	uint n = config::num_keys;
	for (uint i = 0; i < n; i++)
	{
		cfg_key * cfg = config::keys + i;
		if (cfg->key == key && (cfg->mod & mod) == cfg->mod)
		{
			cfg->act->key_event(ev, focus);
			return;
		}
	}
}

void root_window::button_press(XButtonEvent * ev)
{
	uint btn = ev->button - Button1;
	if (btn >= NUM_BUTTONS) return;

	action * act = config::button_press[0].act[btn];
	if (!act) return;

	act->button_event(ev, nullptr);
}

void root_window::button_release(XButtonEvent * ev)
{
	uint btn = ev->button - Button1;
	if (btn >= NUM_BUTTONS) return;

	action * act = config::button_release[0].act[btn];
	if (!act) return;

	act->button_event(ev, nullptr);
}

void root_window::map_request(XMapRequestEvent * ev)
{
	Window w = ev->window;
	window * win;

	if (window::find(w, &win))
		return;

	Window r;
	int x, y;
	uint width, height, t;

	if (XGetGeometry(dpy, w, &r, &x, &y, &width, &height, &t, &t))
	{
		frame_window::create(w, false, x, y, width, height);
	}
}

void root_window::configure_notify(XConfigureEvent * ev)
{
	uint w = ev->width;
	uint h = ev->height;

	s_width = w;
	s_height = h;

	for (frame_window * win = frame_list.first(); win; win = win->next())
	{
		win->check();
	}
}

void root_window::configure_request(XConfigureRequestEvent * ev)
{
	for (frame_window * win = frame_list.first(); win; win = win->next())
	{
		if (win->client.id() == ev->window)
		{
			win->configure_request(ev);
			return;
		}
	}

	XWindowChanges xwc;
	xwc.x = ev->x;
	xwc.y = ev->y;
	xwc.width = ev->width;
	xwc.height = ev->height;
	xwc.border_width = ev->border_width;
	xwc.sibling = ev->above;
	xwc.stack_mode = ev->detail;
	XConfigureWindow(dpy, ev->window, ev->value_mask, &xwc);
}
