#ifndef PIXMAP_HH
#define PIXMAP_HH

#include <X11/Xlib.h>

namespace pixmap
{
	bool load(const char *, Pixmap *);
}

#endif
