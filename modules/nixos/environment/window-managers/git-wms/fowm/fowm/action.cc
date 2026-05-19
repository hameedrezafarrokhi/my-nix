#include <unistd.h>
#include <string.h>

#include "frame.hh"
#include "screen.hh"
#include "action.hh"
#include "main.hh"
#include "info.hh"
#include "menu.hh"
#include "winmenu.hh"
#include "config.hh"

namespace
{

class exec_action : public action
{
private:
	static exec_action * first;

	exec_action * next;
	char cmd[];

	static void exec(const char * cmd)
	{
		if (fork()) return;
		setsid();
		execlp("/bin/sh", "sh", "-c", cmd, nullptr);
		_exit(1);
	}

	exec_action(const exec_action &) = delete;
	exec_action & operator=(const exec_action &) = delete;
	~exec_action() = delete;

	explicit exec_action(const char * c, size_t n) { memcpy(cmd, c, n); }

public:
	static exec_action * create(const char * cmd)
	{
		for (exec_action * p = first; p; p = p->next)
		{
			if (!strcmp(p->cmd, cmd))
				return p;
		}

		size_t len = strlen(cmd) + 1;
		return new (malloc(offsetof(exec_action, cmd) + len)) exec_action(cmd, len);
	}

	void key_event(XKeyEvent *, frame_window *) override { exec(cmd); }
	void button_event(XButtonEvent *, frame_window *) override { exec(cmd); }
};

exec_action * exec_action::first = nullptr;

class send_action : public action
{
private:
	static send_action * first;

	send_action * next;
	uint workspace;

	send_action(const send_action &) = delete;
	send_action & operator=(const send_action &) = delete;
	~send_action() = delete;

	explicit send_action(uint ws) : next(first), workspace(ws) { first = this; }

public:
	static send_action * create(const char * str)
	{
		uint ws;
		if (!to_uint(str, &ws)) return nullptr;

		for (send_action * act = first; act; act = act->next)
		{
			if (act->workspace == ws)
				return act;
		}

		return mnew(send_action, ws);
	}

	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_workspace(workspace);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_workspace(workspace);
	}
};

send_action * send_action::first = nullptr;

class goto_action : public action
{
private:
	static goto_action * first;

	goto_action * next;
	uint workspace;

	goto_action(const goto_action &) = delete;
	goto_action & operator=(const goto_action *) = delete;
	~goto_action() = delete;

	explicit goto_action(uint ws) : next(first), workspace(ws) { first = this; }

public:
	static goto_action * create(const char * str)
	{
		uint ws;
		if (!to_uint(str, &ws)) return nullptr;

		for (goto_action * act = first; act; act = act->next)
		{
			if (act->workspace == ws)
				return act;
		}

		return mnew(goto_action, ws);
	}

	void key_event(XKeyEvent *, frame_window *) override
	{
		screen->set_workspace(workspace);
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		screen->set_workspace(workspace);
	}
};

goto_action * goto_action::first = nullptr;

// frame actions

class raise_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->raise();
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->raise();
	}
}
act_raise;

class lower_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->lower();
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->lower();
	}
}
act_lower;

class raise_lower_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->raise_lower();
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->raise_lower();
	}
}
act_raise_lower;

class maximize_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->maximize(MAXIMIZE_ALL);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->maximize(MAXIMIZE_ALL);
	}
}
act_maximize;

class maximize_horiz_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->maximize(MAXIMIZE_H);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->maximize(MAXIMIZE_H);
	}
}
act_maximize_horiz;

class maximize_vert_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->maximize(MAXIMIZE_V);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->maximize(MAXIMIZE_V);
	}
}
act_maximize_vert;

class shade_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->shade(true);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->shade(true);
	}
}
act_shade;

class unshade_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->shade(false);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->shade(false);
	}
}
act_unshade;

class toggle_shade_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->shade(!win->shaded());
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->shade(!win->shaded());
	}
}
act_toggle_shade;

class stick_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_sticky(true);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_sticky(true);
	}
}
act_stick;

class unstick_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_sticky(false);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_sticky(false);
	}
}
act_unstick;

class toggle_sticky_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_sticky(win->workspace());
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_sticky(win->workspace());
	}
}
act_toggle_sticky;

class set_border_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() | STYLE_BORDER);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() | STYLE_BORDER);
	}
}
act_set_border;

class unset_border_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() & ~STYLE_BORDER);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() & ~STYLE_BORDER);
	}
}
act_unset_border;

class toggle_border_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() ^ STYLE_BORDER);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() ^ STYLE_BORDER);
	}
}
act_toggle_border;

class set_titlebar_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() | STYLE_TITLEBAR);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() | STYLE_TITLEBAR);
	}
}
act_set_titlebar;

class unset_titlebar_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() & ~STYLE_TITLEBAR);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() & ~STYLE_TITLEBAR);
	}
}
act_unset_titlebar;

class toggle_titlebar_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() ^ STYLE_TITLEBAR);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() ^ STYLE_TITLEBAR);
	}
}
act_toggle_titlebar;

class decor_none_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NONE);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NONE);
	}
}
act_decor_none;

class decor_no_title_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NO_TITLE);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NO_TITLE);
	}
}
act_decor_no_title;

class decor_no_border_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NO_BORDER);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NO_BORDER);
	}
}
act_decor_no_border;

class decor_norm_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NORMAL);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(STYLE_NORMAL);
	}
}
act_decor_norm;

class toggle_decor_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() ^ STYLE_NORMAL);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_style(win->style() ^ STYLE_NORMAL);
	}
}
act_toggle_decor;

class send_next_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_workspace(win->workspace() + 1);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_workspace(win->workspace() + 1);
	}
}
act_send_next;

class send_prev_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->set_workspace(win->workspace() - 1);
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->set_workspace(win->workspace() - 1);
	}
}
act_send_prev;

class iconify_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->iconify();
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->iconify();
	}
}
act_iconify;

class close_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->close();
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->close();
	}
}
act_close;

class kill_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window * win) override
	{
		if (win) win->kill();
	}

	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (win) win->kill();
	}
}
act_kill;

// motion actions

class move_action : public action
{
private:
	int a_x = 0, a_y = 0;

public:
	void button_event(XButtonEvent * ev, frame_window *) override
	{
		int x = ev->x_root;
		int y = ev->y_root;

		a_x = x;
		a_y = y;
	}

	void motion_event(XMotionEvent * ev, frame_window * win) override
	{
		if (!win) return;
		button_moved = true;

		int x = win->x();
		int y = win->y();

		int nx = x + ev->x_root - a_x;
		int ny = y + ev->y_root - a_y;
		win->check_snap(&nx, &ny);
		a_x += nx - x;
		a_y += ny - y;
		win->move(nx, ny);
		info_window::set_frame(win);
	}
}
act_move;

class resize_action : public action
{
private:
	int a_x1 = 0, a_y1 = 0;
	int a_x2 = 0, a_y2 = 0;
	bool left = false, top = false;
	bool right = false, bottom = false;

public:
	void button_event(XButtonEvent *, frame_window * win) override
	{
		if (!win) return;

		int x = win->x();
		int y = win->y();
		int w = win->width();
		int h = win->height();

		a_x1 = x;
		a_y1 = y;
		a_x2 = x + w;
		a_y2 = y + h;

		left = false;
		top = false;
		right = false;
		bottom = false;
	}

	void motion_event(XMotionEvent * ev, frame_window * win) override
	{
		if (!win) return;
		if (win->shaded()) return;
		button_moved = true;

		int x = ev->x_root;
		int y = ev->y_root;

		int x1 = win->x();
		int y1 = win->y();

		int x2 = x1 + win->width();
		int y2 = y1 + win->height();

		if (x <= x1)
		{
			left = true;
			right = false;
			x2 = a_x2;
		}

		if (x + 1 >= x2)
		{
			left = false;
			right = true;
			x1 = a_x1;
		}

		if (y <= y1)
		{
			top = true;
			bottom = false;
			y2 = a_y2;
		}

		if (y + 1 >= y2)
		{
			top = false;
			bottom = true;
			y1 = a_y1;
		}

		cfg_style * cfg = config::style + win->style();
		int bx = cfg->left + cfg->right;
		int by = cfg->top + cfg->bottom;

		if (left)
		{
			if ((x2 - x) > bx)
				x1 = x;
		}

		if (right)
		{
			if ((x - x1) > bx)
				x2 = x + 1;
		}

		if (top)
		{
			if ((y2 - y) > by)
				y1 = y;
		}

		if (bottom)
		{
			if ((y - y1) > by)
				y2 = y + 1;
		}

		uint w = x2 - x1;
		uint h = y2 - y1;

		if (w != win->width() || h != win->height())
		{
			int grav = left ? (top ? SouthEastGravity : NorthEastGravity) :
				(top ? SouthWestGravity : NorthWestGravity);
			win->resize(grav, x1, y1, w, h);
			info_window::set_frame(win);
		}
	}
}
act_resize;

// other actions

class circulate_up_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		XCirculateSubwindowsUp(dpy, screen->id());
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		XCirculateSubwindowsUp(dpy, screen->id());
	}
}
act_circulate_up;

class circulate_down_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		XCirculateSubwindowsDown(dpy, screen->id());
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		XCirculateSubwindowsDown(dpy, screen->id());
	}
}
act_circulate_down;

class close_menus_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		menu_window::close_all();
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		menu_window::close_all();
	}
}
act_close_menus;

class goto_next_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		screen->set_workspace(screen->workspace() + 1);
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		screen->set_workspace(screen->workspace() + 1);
	}
}
act_goto_next;

class goto_prev_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		screen->set_workspace(screen->workspace() - 1);
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		screen->set_workspace(screen->workspace() - 1);
	}
}
act_goto_prev;

class exit_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		running = false;
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		running = false;
	}
}
act_exit;

class restart_action : public action
{
public:
	void key_event(XKeyEvent *, frame_window *) override
	{
		restart = true;
		running = false;
	}

	void button_event(XButtonEvent *, frame_window *) override
	{
		restart = true;
		running = false;
	}
}
act_restart;

action act_nop;

// end of actions

struct act_ptr
{
	const char * name;
	action * ptr;
};

const act_ptr actions[] =
{
	{ "Raise", &act_raise },
	{ "Lower", &act_lower },
	{ "RaiseLower", &act_raise_lower },
	{ "Maximize", &act_maximize },
	{ "MaximizeHoriz", &act_maximize_horiz },
	{ "MaximizeVert", &act_maximize_vert },
	{ "Shade", &act_shade },
	{ "UnShade", &act_unshade },
	{ "ToggleShade", &act_toggle_shade },
	{ "Stick", &act_stick },
	{ "UnStick", &act_unstick },
	{ "ToggleSticky", &act_toggle_sticky },
	{ "SetBorder", &act_set_border },
	{ "UnsetBorder", &act_unset_border },
	{ "ToggleBorder", &act_toggle_border },
	{ "SetTitlebar", &act_set_titlebar },
	{ "UnsetTitlebar", &act_unset_titlebar },
	{ "ToggleTitlebar", &act_toggle_titlebar },
	{ "DecorNone", &act_decor_none },
	{ "DecorNoTitle", &act_decor_no_title },
	{ "DecorNoBorder", &act_decor_no_border },
	{ "DecorNormal", &act_decor_norm },
	{ "ToggleDecoration", &act_toggle_decor },
	{ "SendToNext", &act_send_next },
	{ "SendToPrev", &act_send_prev },
	{ "Iconify", &act_iconify },
	{ "Close", &act_close },
	{ "Kill", &act_kill },
	{ "Move", &act_move },
	{ "Resize", &act_resize },
	{ "CirculateUp", &act_circulate_up },
	{ "CirculateDown", &act_circulate_down },
	{ "WindowMenu", &winmenu_action::instance },
	{ "CloseMenus", &act_close_menus },
	{ "GotoNext", &act_goto_next },
	{ "GotoPrev", &act_goto_prev },
	{ "Exit", &act_exit },
	{ "Restart", &act_restart },
	{ "nop", &act_nop }
};

}

menu_action * menu_action::first = nullptr;

menu_action * menu_action::find(const char * s)
{
	for (menu_action * menu = first; menu; menu = menu->next)
	{
		if (str_eq(menu->menu.name, s))
		{
			return menu;
		}
	}

	return nullptr;
}

void menu_action::key_event(XKeyEvent * ev, frame_window * fwin)
{
	menu_window::toggle(&menu, fwin, ev->x_root, ev->y_root);
}

void menu_action::button_event(XButtonEvent * ev, frame_window * fwin)
{
	menu_window::toggle(&menu, fwin, ev->x_root, ev->y_root);
}

action * action::create(const char * n, const char * a)
{
	if (str_eq(n, "Menu"))
	{
		if (!a) return nullptr;
		return menu_action::find(a);
	}

	if (str_eq(n, "Exec"))
	{
		if (!a) return nullptr;
		return exec_action::create(a);
	}

	if (str_eq(n, "SendTo"))
	{
		if (!a) return nullptr;
		return send_action::create(a);
	}

	if (str_eq(n, "Goto"))
	{
		if (!a) return nullptr;
		return goto_action::create(a);
	}

	if (a) return nullptr;

	for (const act_ptr & p : actions)
	{
		if (str_eq(p.name, n))
			return p.ptr;
	}

	return nullptr;
}

void action::button_event(XButtonEvent *, frame_window *) {}
void action::motion_event(XMotionEvent *, frame_window *) {}
void action::key_event(XKeyEvent *, frame_window *) {}
