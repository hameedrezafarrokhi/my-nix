#ifndef MENU_HH
#define MENU_HH

#ifdef USE_XFT
#include <X11/Xft/Xft.h>
#endif

#include "utility.hh"

struct cfg_menu;
struct cfg_menu_item;

class menuitem_window;

class menu_window final : public window
{
private:
	cfg_menu * w_cfg;
	Window w_frame;
	menu_window * w_sub_menu;
	menuitem_window * w_items;
	udecor_window * w_decor;
	uint w_num_items;
	uint w_num_decor;

	int w_x, w_y;
	uint w_width, w_height;
	bool w_mapped;

	explicit menu_window(Window win) : window(win) {}
	~menu_window() {}

public:
	static void init();
	static void toggle(cfg_menu *, frame_window *, int, int);
	static void toggle_wm(int, int);
	static void close_all();

	void open(int, int);
	void close();

	inline void enter(menuitem_window *);

	void button_press(XButtonEvent *) override;
	void button_release(XButtonEvent *) override;
	void motion_notify(XMotionEvent *) override;
};

class menuitem_window final : public window
{
private:
	menu_window * w_menu;
#ifdef USE_XFT
	XftDraw * w_draw;
#else
	GC w_gc;
#endif
	const char * w_text;
	uint w_text_len;
	int a_x;
	static int a_y;
	bool w_arrow;
	bool w_over;

	explicit menuitem_window(Window win) : window(win) {}
	~menuitem_window() {}

	void set_background();

public:
	inline static void init();

	static menuitem_window * create(uint, menu_window *, cfg_menu_item *, int , int, uint);
	static void destroy(menuitem_window *, uint);

	void enter_notify(XCrossingEvent *) override;
	void leave_notify(XCrossingEvent *) override;
	void expose(XExposeEvent *) override;
};

#endif
