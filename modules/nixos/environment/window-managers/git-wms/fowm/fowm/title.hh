#ifndef TITLE_HH
#define TITLE_HH

#ifdef USE_XFT
#include <X11/Xft/Xft.h>
#endif

#include "main.hh"
#include "utility.hh"

class title_window final : public fdecor_window<title_window>
{
private:
#ifdef USE_XFT
	XftDraw * w_draw;
#else
	GC w_gc;
#endif
	udecor_window * w_decor;
	uint w_width, w_height;
	int t_x, t_y;
	uint w_num_decor;

	explicit title_window(Window win, frame_window * fwin, uchar act, uchar num) :
		fdecor_window(win, fwin, 0, act, num) {}
	~title_window() {}

	void calc_title();

public:
	static title_window * create(frame_window *);
	void destroy();

	uint width() { return w_width; }
	uint height() { return w_height; }

	void set_background();
	void set_size();

	void set_title()
	{
		calc_title();
		XClearWindow(dpy, id());
		expose(nullptr);
	}

	void expose(XExposeEvent *) override;
};

#endif
