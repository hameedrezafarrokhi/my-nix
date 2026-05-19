#ifndef INFO_HH
#define INFO_HH

#ifdef USE_XFT
#include <X11/Xft/Xft.h>
#endif

#include "utility.hh"

#define INFO_TEXT_SIZE 48

class frame_window;

class info_window final : public window
{
private:
	udecor_window * w_decor;
	uint w_num_decor;
	uint w_text_len;
#ifdef USE_XFT
	XftDraw * w_draw;
#else
	GC w_gc;
#endif
	int w_width;
	char w_text[INFO_TEXT_SIZE];

	static bool is_ws;
	static info_window * instance;

	explicit info_window(Window win) :
		window(win) {}
	~info_window() {}

	void update();
	void update_frame(frame_window *);
	void update_workspace(uint);
	void unmap();

public:
	static void init();
	static void set_frame(frame_window * fwin) { instance->update_frame(fwin); }
	static void set_workspace(uint ws) { instance->update_workspace(ws); }
	static void clear_frame() { if (!is_ws) instance->unmap(); }
	static void clear_workspace() { if (is_ws) instance->unmap(); }

	static Window get_id() { return instance->id(); }

	void expose(XExposeEvent *) override;
};

#endif
