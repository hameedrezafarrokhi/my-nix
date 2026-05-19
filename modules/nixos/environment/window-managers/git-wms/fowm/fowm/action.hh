#ifndef ACTION_HH
#define ACTION_HH

#include <X11/Xlib.h>

class frame_window;

class action
{
public:
	virtual void button_event(XButtonEvent *, frame_window *);
	virtual void motion_event(XMotionEvent *, frame_window *);
	virtual void key_event(XKeyEvent *, frame_window *);

	static action * create(const char *, const char *);
};

class menu_window;
struct cfg_menu_item;

struct cfg_menu
{
	cfg_menu_item * items;
	menu_window * window;
	uint nitems;
	char name[];
};

class menu_action : public action
{
public:
	static menu_action * first;
	menu_action * next;
	cfg_menu menu;

	constexpr menu_action() : next(), menu() {}

	void key_event(XKeyEvent *, frame_window *) override;
	void button_event(XButtonEvent *, frame_window *) override;

	static menu_action * find(const char *);
};

#endif
