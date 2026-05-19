#ifndef FRAME_HH
#define FRAME_HH

#include "client.hh"
#include "title.hh"
#include "border.hh"

#define MAXIMIZE_H 1
#define MAXIMIZE_V 2
#define MAXIMIZE_ALL 3

class window_list;
class frame_window;

class window_node
{
	friend window_list;
	friend frame_window;

private:
	frame_window * n_next;

	explicit window_node() : n_next(nullptr) {}
	~window_node() {}
};

class frame_window final : public window
{
public:
	window_node node;
	client_window client;

private:
	title_window * w_title;
	border_window * w_borders;
	char * w_name;
	XSizeHints * w_hints;

	uint w_num_borders;
	uint w_name_len;

	int w_x, w_y;
	uint w_width, w_height;

	int saved_x, saved_y;
	uint saved_width, saved_height;

	uint w_workspace;
	uint w_shade;

	uchar w_max;
	uchar w_style;
	uchar saved_style;

	bool w_shaped;
	bool w_focused;
	bool w_mapped;
	bool w_iconified;
	bool w_hidden;
	bool w_ewmh_name;
	bool w_input;
	bool w_delete_window;
	bool w_take_focus;
	bool w_fullscreen;

	explicit frame_window(Window fwin, Window cwin) :
		window(fwin), client(this, cwin) {}
	~frame_window() {}

	void send_message(Atom);
	void set_state(ulong);
	void fetch_name();

	void set_shape();
	void send_configure_notify();

public:
	static uchar read_mwm_hints(Window, uchar);
	static void read_size_hints(Window, XSizeHints *);
	static void set_frame_extents(Window, uchar);

	static frame_window * create(Window, bool, int, int, uint, uint);
	void destroy();

	int read_wm_hints();
	void read_wm_protos();

	void read_motif_hints()
	{
		set_style(read_mwm_hints(client.id(), w_style));
	}

	void read_normal_hints()
	{
		read_size_hints(client.id(), w_hints);
	}

	void check();
	void check_snap(int *, int *);
	void move(int, int);
	void resize(int, int, int, uint, uint);
	void maximize(uchar);
	void shade(bool);
	void set_fullscreen(bool);

	void deiconify();
	void iconify();
	void map();
	void unmap();
	void show();
	void close();

	void set_workspace(uint);
	void set_sticky(bool);
	void set_style(uchar);
	void set_title();
	void focus();

	frame_window * next() { return node.n_next; }

	int x() { return w_x; }
	int y() { return w_y; }
	uint width() { return w_width; }
	uint height() { return w_height; }
	uint workspace() { return w_workspace; }

	uchar style() { return w_style; }
	bool focused() { return w_focused; }
	bool mapped() { return w_mapped; }
	bool iconified() { return w_iconified; }
	bool hidden() { return w_hidden; }
	bool shaded() { return w_shade != 0; }
	bool fullscreen() { return w_fullscreen; }

	const char * name() { return w_name; }
	uint name_len() { return w_name_len; }
	bool ewmh_name() { return w_ewmh_name; }

	const XSizeHints * size_hints() { return w_hints; }

	void update_shape() { if (w_shaped) set_shape(); }

	void set_focused()
	{
		w_focused = 1;
		if (w_title) w_title->set_background();
		border_window::set_background(w_borders, w_num_borders, w_style);
	}

	void unset_focused()
	{
		w_focused = 0;
		if (w_title) w_title->set_background();
		border_window::set_background(w_borders, w_num_borders, w_style);
	}

	void raise() { XRaiseWindow(dpy, id()); }
	void lower() { XLowerWindow(dpy, id()); }
	void kill() { XKillClient(dpy, client.id()); }

	void raise_lower()
	{
		XWindowChanges xwc;
		xwc.stack_mode = Opposite;
		XConfigureWindow(dpy, id(), CWStackMode, &xwc);
	}

	void enter_notify(XCrossingEvent *) override;
	void leave_notify(XCrossingEvent *) override;
	void unmap_notify(XUnmapEvent *) override;
	void map_notify(XMapEvent *) override;
	void map_request(XMapRequestEvent *) override;
	void configure_request(XConfigureRequestEvent *) override;

	static void xclient_message(XClientMessageEvent *);
};

#endif
