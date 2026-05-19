#ifndef DECORFUNC_HH
#define DECORFUNC_HH

#include "main.hh"
#include "decoration.hh"
#include "action.hh"
#include "config.hh"

template <class T>
void fdecor_window<T>::button_press(XButtonEvent * ev)
{
	w_press = true;
	if (w_num > 3) set_background();

	uint btn = ev->button - Button1;
	if (btn >= NUM_BUTTONS) return;

	action * act = config::button_press[w_act].act[btn];
	if (!act) return;

	act->button_event(ev, w_frame);
}

template <class T>
void fdecor_window<T>::button_release(XButtonEvent * ev)
{
	w_press = false;
	if (w_num > 3) set_background();

	uint btn = ev->button - Button1;
	if (btn >= NUM_BUTTONS) return;
	if (button_moved) return;

	action * act = config::button_release[w_act].act[btn];
	if (!act) return;

	act->button_event(ev, w_frame);
}

template <class T>
void fdecor_window<T>::motion_notify(XMotionEvent * ev)
{
	uint btn = pressed_button - Button1;
	if (btn >= NUM_BUTTONS) return;

	action * act = config::button_press[w_act].act[btn];
	if (!act) return;

	act->motion_event(ev, w_frame);
}

template <class T>
void fdecor_window<T>::enter_notify(XCrossingEvent *)
{
	w_over = true;
	if (w_num > 2) set_background();
}

template <class T>
void fdecor_window<T>::leave_notify(XCrossingEvent *)
{
	w_over = false;
	if (w_num > 2) set_background();
}

#endif
