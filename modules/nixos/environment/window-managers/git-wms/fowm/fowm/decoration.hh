#ifndef DECORORATION_HH
#define DECORORATION_HH

#include "window.hh"

struct cfg_rect;
class frame_window;

class decor_window : public window
{
	template <class T> friend class fdecor_window;

private:
	frame_window * w_frame;
	uint w_idx;
	uchar w_act;
	uchar w_num;
	bool w_over;
	bool w_press;

protected:
	explicit decor_window(Window win, frame_window * fwin, uint idx, uchar act, uchar num) :
		window(win), w_frame(fwin), w_idx(idx), w_act(act), w_num(num), w_over(), w_press() {}
	~decor_window() {}

public:
	static Window create_window(Window, uint, rectangle *, ulong, Pixmap);
	static void make_rectangle(rectangle *, cfg_rect *, uint, uint);
	static void set_background(Window, ulong, Pixmap);
	static void set_size(Window, rectangle *);

	static uint color_index(uint n, bool f)
	{
		return n > 1 && f ? 1 : 0;
	}

	uint color_index();

	frame_window * frame() { return w_frame; }
	uint index() { return w_idx; }
	bool over() { return w_over; }
	bool pressed() { return w_press; }
};

template <class T>
class fdecor_window : public decor_window
{
	friend T;

private:
	explicit fdecor_window(Window win, frame_window * fwin, uint idx, uchar act, uchar num) :
		decor_window(win, fwin, idx, act, num) {}
	~fdecor_window() {}

	void set_background() { static_cast<T *>(this)->set_background(); }

public:
	void button_press(XButtonEvent *) override;
	void button_release(XButtonEvent *) override;
	void motion_notify(XMotionEvent *) override;
	void enter_notify(XCrossingEvent *) override;
	void leave_notify(XCrossingEvent *) override;
};

#endif
