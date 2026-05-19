#include <string.h>

#include "winlist.hh"
#include "menu.hh"
#include "winmenu.hh"
#include "config.hh"

winmenu_action winmenu_action::instance;
bool winmenu_action::clean = false;

void winmenu_action::init()
{
	instance.next = menu_action::first;
	menu_action::first = &instance;
}

void winmenu_action::key_event(XKeyEvent * ev, frame_window *)
{
	menu_window::toggle_wm(ev->x_root, ev->y_root);
}

void winmenu_action::button_event(XButtonEvent * ev, frame_window *)
{
	menu_window::toggle_wm(ev->x_root, ev->y_root);
}

namespace
{

class win_action : public action
{
public:
	Window frame;

	explicit win_action(Window f) : frame(f) {}

	void button_event(XButtonEvent *, frame_window *)
	{
		frame_window * fwin = screen->find(frame);
		if (fwin) fwin->show();
	}
};

}

void menu_window::toggle_wm(int x , int y)
{
	cfg_menu * cfg = &winmenu_action::instance.menu;
	menu_window * win = cfg->window;

	if (win->w_mapped)
	{
		win->close();
		return;
	}

	if (!winmenu_action::clean)
	{
		cfg_menu_item * items = cfg->items;
		if (items)
		{
			uint n = cfg->nitems;
			for (uint i = 0; i < n; i++)
			{
				free(items[i].act);
			}
			free(items);

			cfg->items = nullptr;
			cfg->nitems = 0;
		}

		uint n = screen->frame_list.length();
		if (!n) return;

		items = malloc<cfg_menu_item>(n);
		cfg->items = items;
		cfg->nitems = n;

		uint tw = 1;

		frame_window * fwin = screen->frame_list.first();
		for (uint i = 0; i < n; i++)
		{
			size_t len = fwin->name_len();
			char * act = malloc<char>(sizeof(win_action) + 1 + len);
			char * name = act + sizeof(win_action);

			items[i].name = name;
			items[i].act = new (act) win_action(fwin->id());

			if (fwin->name())
				memcpy(name, fwin->name(), len + 1);
			else
				name[0] = 0;

#ifdef USE_XFT
			XGlyphInfo info;
			XftTextExtentsUtf8(dpy, config::font, str_cast(name), len, &info);
			uint t = info.xOff;
#else
			uint t = XTextWidth(config::font, name, len);
#endif
			if (t > tw) tw = t;

			fwin = fwin->next();
		}

		cfg_style * csp = config::style + STYLE_MENU;

		tw += csp->util.left + csp->util.right;
		if (config::max_menu_width && tw > config::max_menu_width)
			tw = config::max_menu_width;

		uint w = tw + csp->left + csp->right;
		uint h = csp->util.height * n + csp->top + csp->bottom;
		win->w_width = w;
		win->w_height = h;
		XResizeWindow(dpy, win->id(), w, h);

		if (win->w_items)
		{
			menuitem_window::destroy(win->w_items, win->w_num_items);
		}

		win->w_num_items = n;
		win->w_items = menuitem_window::create(n, win, items, csp->left, csp->top, tw);

		udecor_window::set_size(win->w_decor, win->w_num_decor, csp->borders, w, h);

		winmenu_action::clean = true;
	}

	win->open(x, y);
}
