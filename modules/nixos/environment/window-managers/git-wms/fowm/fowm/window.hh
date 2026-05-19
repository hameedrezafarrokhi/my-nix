#ifndef WINDOW_HH
#define WINDOW_HH

#include <X11/Xlib.h>
#include <X11/extensions/shape.h>

#include "misc.hh"

struct rectangle
{
	int x, y;
	int width, height;
};

class window
{
	class hashtable;
	friend hashtable;

private:
	static hashtable db;

	window * w_next;
	Window w_id;

	window(const window &) = delete;
	window & operator=(const window &) = delete;

protected:
	explicit window(Window win);
	~window();

public:
	Window id() { return w_id; }

	static bool find(Window, window **);

	virtual void key_press(XKeyEvent *);
	virtual void button_press(XButtonEvent *);
	virtual void button_release(XButtonEvent *);
	virtual void motion_notify(XMotionEvent *);
	virtual void enter_notify(XCrossingEvent *);
	virtual void leave_notify(XCrossingEvent *);
	virtual void focus_in(XFocusChangeEvent *);
	virtual void focus_out(XFocusChangeEvent *);
	virtual void expose(XExposeEvent *);
	virtual void destroy_notify(XDestroyWindowEvent *);
	virtual void unmap_notify(XUnmapEvent *);
	virtual void map_notify(XMapEvent *);
	virtual void map_request(XMapRequestEvent *);
	virtual void configure_notify(XConfigureEvent *);
	virtual void configure_request(XConfigureRequestEvent *);
	virtual void property_notify(XPropertyEvent *);
	virtual void client_message(XClientMessageEvent *);
	virtual void shape_event(XShapeEvent *);
};

#endif
