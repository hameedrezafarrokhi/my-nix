#ifndef CURSOR_HH
#define CURSOR_HH

#include <X11/Xlib.h>

#include "misc.hh"

namespace cursor
{
	Cursor load(const char *);
}

#endif
