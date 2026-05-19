#ifndef SCREEN_HH
#define SCREEN_HH

#include "main.hh"
#include "window.hh"

class frame_window;

class window_list
{
private:
	frame_window * l_first;
	frame_window * l_last;

	window_list(const window_list &) = delete;
	window_list & operator=(const window_list &) = delete;

public:
	explicit window_list() : l_first(nullptr), l_last(nullptr) {}
	~window_list() {}

	frame_window * first() { return l_first; }
	inline void add(frame_window *);
	inline void remove(frame_window *);
	inline uint length();
};

class root_window final : public window
{
private:
	uint s_width;
	uint s_height;
	Colormap s_colormap;
	uint s_workspace;
#ifdef USE_XFT
	int s_number;
	Visual * s_visual;
	GC s_gc;
#endif

	explicit root_window(int scr) : window(RootWindow(dpy, scr)) {}
	~root_window() {}

public:
	frame_window * focus;
	window_list frame_list;

	static root_window * create(int);
	void destroy();
	void init();

	void set_workspace(uint);
	frame_window * find(Window);

	uint width() { return s_width; }
	uint height() { return s_height; }
	Colormap colormap() { return s_colormap; }
	uint workspace() { return s_workspace; }
#ifdef USE_XFT
	int number() { return s_number; }
	Visual * visual() { return s_visual; }
	GC gc() { return s_gc; }
#endif

	void key_press(XKeyEvent *) override;
	void button_press(XButtonEvent *) override;
	void button_release(XButtonEvent *) override;
	void map_request(XMapRequestEvent *) override;
	void configure_notify(XConfigureEvent *) override;
	void configure_request(XConfigureRequestEvent *) override;
};

#endif
