#ifndef UTILITY_HH
#define UTILITY_HH

#include "decoration.hh"

struct cfg_border;

class udecor_window final : public window
{
private:
	explicit udecor_window(Window win) : window(win) {}
	~udecor_window() {}

	void set_background(ulong color, Pixmap pmap) { decor_window::set_background(id(), color, pmap); }
	void set_size(rectangle * rect) { decor_window::set_size(id(), rect); }

public:
	static udecor_window * create(uint, window *, cfg_border *, uint, uint, uint);
	static void destroy(udecor_window *, uint);

	static void set_background(udecor_window *, uint, cfg_border *, uint);
	static void set_size(udecor_window *, uint, cfg_border *, uint, uint);
};

#endif
