#ifndef WINLIST_HH
#define WINLIST_HH

#include "screen.hh"
#include "frame.hh"

void window_list::add(frame_window * w)
{
	if (l_last)
	{
		l_last->node.n_next = w;
	}
	else
	{
		l_first = w;
	}

	l_last = w;
	w->node.n_next = nullptr;
}

void window_list::remove(frame_window * w)
{
	frame_window * p = nullptr;
	frame_window ** ptr = &l_first;

	while (*ptr)
	{
		if (*ptr == w)
		{
			*ptr = w->node.n_next;
			if (l_last == w) l_last = p;
			return;
		}

		p = *ptr;
		ptr = &p->node.n_next;
	}
}

uint window_list::length()
{
	uint n = 0;

	frame_window * p = l_first;
	while (p)
	{
		n++;
		p = p->node.n_next;
	}

	return n;
}

#endif
