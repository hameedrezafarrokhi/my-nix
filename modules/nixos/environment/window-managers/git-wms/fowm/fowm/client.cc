#include <X11/Xatom.h>

#include "frame.hh"
#include "screen.hh"
#include "atoms.hh"
#include "action.hh"
#include "config.hh"

void client_window::button_press(XButtonEvent * ev)
{
	uint btn = ev->button - Button1;
	if (btn >= NUM_BUTTONS) return;

	action * act = config::button_press[config::mod_act].act[btn];
	if (!act) return;

	act->button_event(ev, w_frame);
}

void client_window::button_release(XButtonEvent * ev)
{
	uint btn = ev->button - Button1;
	if (btn >= NUM_BUTTONS) return;
	if (button_moved) return;

	action * act = config::button_release[config::mod_act].act[btn];
	if (!act) return;

	act->button_event(ev, w_frame);
}

void client_window::motion_notify(XMotionEvent * ev)
{
	uint btn = pressed_button - Button1;
	if (btn >= NUM_BUTTONS) return;

	action * act = config::button_press[config::mod_act].act[btn];
	if (!act) return;

	act->motion_event(ev, w_frame);
}

static Bool focus_in_cb(Display *, XEvent *ev, XPointer arg)
{
	if (ev->type == FocusIn)
	{
		bool * found = reinterpret_cast<bool *>(arg);
		*found = true;
	}
	return False;
}

void client_window::focus_in(XFocusChangeEvent *)
{
	if (!w_frame->mapped())
		return;

	w_frame->set_focused();

	frame_window * fwin = screen->focus;
	if (!fwin || fwin == w_frame)
		return;

	bool found = false;
	XCheckIfEvent(dpy, nullptr, focus_in_cb, reinterpret_cast<XPointer>(&found));
	if (found) return;
		
	fwin->focus();
}

void client_window::focus_out(XFocusChangeEvent * ev)
{
	if (ev->detail == NotifyInferior)
		return;

	w_frame->unset_focused();
}

void client_window::destroy_notify(XDestroyWindowEvent *)
{
	w_frame->destroy();
}

void client_window::unmap_notify(XUnmapEvent * ev)
{
	if (w_frame->mapped() || ev->send_event)
		w_frame->destroy();
}

void client_window::property_notify(XPropertyEvent * ev)
{
	Atom atom = ev->atom;
	if (atom == XA_WM_NAME)
	{
		if (!w_frame->ewmh_name())
			w_frame->set_title();
	}
	else if (atom == XA_WM_HINTS)
	{
		w_frame->read_wm_hints();
	}
	else if (atom == XA_WM_NORMAL_HINTS)
	{
		w_frame->read_normal_hints();
	}
	else if (atom == NET_WM_NAME)
	{
		w_frame->set_title();
	}
	else if (atom == MOTIF_WM_HINTS)
	{
		w_frame->read_motif_hints();
	}
	else if (atom == WM_PROTOCOLS)
	{
		w_frame->read_wm_protos();
	}
}

void client_window::client_message(XClientMessageEvent * ev)
{
	if (ev->message_type == WM_CHANGE_STATE)
	{
		if (ev->data.l[0] != IconicState)
			w_frame->deiconify();
		else if (!w_frame->fullscreen())
			w_frame->iconify();
	}
	else if (ev->message_type == NET_WM_STATE)
	{
		Atom a1 = ev->data.l[1];
		Atom a2 = ev->data.l[2];

		if (a1 == NET_WM_STATE_FULLSCREEN ||
			a2 == NET_WM_STATE_FULLSCREEN)
		{
			switch(ev->data.l[0])
			{
			case 0:
				w_frame->set_fullscreen(false);
				break;
			case 1:
				w_frame->set_fullscreen(true);
				break;
			case 2:
				w_frame->set_fullscreen(!w_frame->fullscreen());
				break;
			}
		}
	}
}

void client_window::shape_event(XShapeEvent *)
{
	w_frame->update_shape();
}
