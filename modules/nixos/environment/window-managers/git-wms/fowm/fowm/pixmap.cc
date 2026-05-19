#include <stdio.h>
#include <string.h>
#include <alloca.h>

#include <X11/xpm.h>

#include "pixmap.hh"
#include "config.hh"
#include "screen.hh"

namespace
{

class xpixmap
{
private:
	static xpixmap * first;

	xpixmap * next;
	Pixmap pmap;
	char name[];

	xpixmap(const xpixmap &) = delete;
	xpixmap & operator=(const xpixmap &) = delete;
	~xpixmap() = delete;

	explicit xpixmap(const char * str, Pixmap pm, size_t len) :
		next(first), pmap(pm)
	{
		first = this;
		memcpy(name, str, len);
	}

public:
	static xpixmap * create(const char * str, Pixmap pm, size_t len)
	{
		return new (malloc(offsetof(xpixmap, name) + len)) xpixmap(str, pm, len);
	}

	static bool find(const char * name, Pixmap * pm)
	{
		for (xpixmap * p = first; p; p = p->next)
		{
			if (!strcmp(p->name, name))
			{
				*pm = p->pmap;
				return true;
			}
		}

		return false;
	}
};

xpixmap * xpixmap::first = nullptr;

}

bool pixmap::load(const char * file, Pixmap * pm)
{
	if (xpixmap::find(file, pm))
	{
		return true;
	}

	size_t len = strlen(file);
	char * path = static_cast<char *>(alloca(len + config::dirlen + 2));
	sprintf(path, "%s/%s", config::confdir, file);

	if (XpmReadFileToPixmap(dpy, screen->id(), path, pm, nullptr, nullptr))
	{
		fprintf(stderr, "Failed to load pixmap: %s\n", path);
		return false;
	}

	xpixmap::create(file, *pm, len + 1);
	return true;
}
