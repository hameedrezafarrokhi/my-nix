#include "window.hh"

#define INITHASHMASK 127

class window::hashtable
{
	friend window;

private:
	window ** table;
	uint mask;
	uint num_entries;

	window ** hash(Window id)
	{
		return table + (((id >> 21) ^ id) & mask);
	}

	void resize();
};

window::hashtable window::db = {};

void window::hashtable::resize()
{
	window ** otable = table;
	uint omask = mask;

	uint n = INITHASHMASK+1;
	while (n < num_entries) n += n;
	table = calloc<window *>(n);
	mask = n - 1;

	if (!otable) return;
	for (uint i = 0; i <= omask; i++)
	{
		window * p = otable[i];
		while (p)
		{
			window * next = p->w_next;
			window ** head = hash(p->w_id);
			p->w_next = *head;
			*head = p;
			p = next;
		}
	}
	free(otable);
}

window::window(Window id) : w_id(id)
{
	db.num_entries++;
	if (db.num_entries > (db.mask << 1))
		db.resize();
	window ** p = db.hash(id);
	w_next = *p;
	*p = this;
}

window::~window()
{
	window ** p = db.hash(w_id);
	while (*p)
	{
		if (*p == this)
		{
			*p = w_next;
			break;
		}
		p = &(*p)->w_next;
	}

	db.num_entries--;
	if (db.num_entries < (db.mask >> 1) && db.mask > INITHASHMASK)
		db.resize();
}

bool window::find(Window id, window ** p)
{
	for (window * w = *db.hash(id); w; w = w->w_next)
	{
		if (w->w_id == id)
		{
			*p = w;
			return true;
		}
	}
	return false;
}

void window::key_press(XKeyEvent *) {}
void window::button_press(XButtonEvent *) {}
void window::button_release(XButtonEvent *) {}
void window::motion_notify(XMotionEvent *) {}
void window::enter_notify(XCrossingEvent *) {}
void window::leave_notify(XCrossingEvent *) {}
void window::focus_in(XFocusChangeEvent *) {}
void window::focus_out(XFocusChangeEvent *) {}
void window::expose(XExposeEvent *) {}
void window::destroy_notify(XDestroyWindowEvent *) {}
void window::unmap_notify(XUnmapEvent *) {}
void window::map_notify(XMapEvent *) {}
void window::map_request(XMapRequestEvent *) {}
void window::configure_notify(XConfigureEvent *) {}
void window::configure_request(XConfigureRequestEvent *) {}
void window::property_notify(XPropertyEvent *) {}
void window::client_message(XClientMessageEvent *) {}
void window::shape_event(XShapeEvent *) {}
