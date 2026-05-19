#ifndef MAIN_HH
#define MAIN_HH

#include <X11/Xlib.h>

#include "misc.hh"

extern Display * dpy;
extern class root_window * screen;
extern bool restart;
extern bool running;
extern uint pressed_button;
extern bool button_moved;
extern Time timestamp;

#endif
