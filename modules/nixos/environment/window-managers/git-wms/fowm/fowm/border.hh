#ifndef BORDER_H
#define BORDER_H

#include "decoration.hh"

struct cfg_border;

class border_window final : public fdecor_window<border_window>
{
private:
	explicit border_window(Window win, frame_window * fwin, uint idx, uchar act, uchar num, uint) :
		fdecor_window(win, fwin, idx, act, num) {}
	~border_window() {}

	void set_background(ulong color, Pixmap pmap) { decor_window::set_background(id(), color, pmap); }
	void set_size(rectangle * rect) { decor_window::set_size(id(), rect); }

public:
	static border_window * create(uint, frame_window *);
	static void destroy(border_window *, uint);

	static void set_size(border_window *, uint, cfg_border *, uint, uint);
	static void set_background(border_window *, uint, uint);

	void set_background();
};

#endif
