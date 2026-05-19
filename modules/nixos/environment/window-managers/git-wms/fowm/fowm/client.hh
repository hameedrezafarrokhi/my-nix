#ifndef CLIENT_H
#define CLIENT_H

#include "window.hh"

class frame_window;

class client_window final : public window
{
private:
	frame_window * w_frame;

public:
	explicit client_window(frame_window * fwin, Window win) :
		window(win), w_frame(fwin) {}
	~client_window() {}

	frame_window * frame() { return w_frame; }

	void button_press(XButtonEvent *) override;
	void button_release(XButtonEvent *) override;
	void motion_notify(XMotionEvent *) override;
	void focus_in(XFocusChangeEvent *) override;
	void focus_out(XFocusChangeEvent *) override;
	void destroy_notify(XDestroyWindowEvent *) override;
	void unmap_notify(XUnmapEvent *) override;
	void property_notify(XPropertyEvent *) override;
	void client_message(XClientMessageEvent *) override;
	void shape_event(XShapeEvent *) override;
};

#endif
