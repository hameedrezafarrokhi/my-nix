#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <poll.h>

#include "config.hh"
#include "screen.hh"
#include "frame.hh"
#include "atoms.hh"
#include "info.hh"
#include "menu.hh"
#include "winmenu.hh"

Display * dpy = nullptr;
root_window * screen = nullptr;
bool restart = false;
bool running = false;
uint pressed_button = 0;
bool button_moved = false;
Time timestamp = CurrentTime;

static volatile bool got_alarm = false;

static int error_handler(Display *, XErrorEvent *)
{
	return 0;
}

static void on_alarm(int)
{
	got_alarm = true;
}

static void set_signals()
{
	struct sigaction sa = {};
	sa.sa_handler = SIG_IGN;
	sa.sa_flags = SA_NOCLDWAIT;
	sigaction(SIGCHLD, &sa, nullptr);
	sa.sa_handler = on_alarm;
	sa.sa_flags = SA_RESTART;
	sigaction(SIGALRM, &sa, nullptr);
}

int main(int argc, char ** argv)
{
	const char * display = nullptr;
	const char * confdir = nullptr;

	for (int i = 1; i < argc; ++i)
	{
		if (!strcmp("-display", argv[i]) && i + 1 < argc)
		{
			display = argv[++i];
			setenv("DISPLAY", display, 1);
		}
		else if (!strcmp("-config", argv[i]) && i + 1 < argc)
		{
			confdir = argv[++i];
		}
		else
		{
			fprintf(stderr, "Usage: %s [-display dpy] [-config dir]\n", argv[0]);
			return 1;
		}
	}

	dpy = XOpenDisplay(display);
	if (!dpy)
	{
		if (!display)
		{
			display = getenv("DISPLAY");
			if (!display) display = "";
		}

		fprintf(stderr, "%s: Can't open display: %s\n", argv[0], display);
		return 1;
	}

	set_signals();

	int shape_event = 0;
	int shape_error = 0;
	XShapeQueryExtension(dpy, &shape_event, &shape_error);

	atoms::init();

	screen = root_window::create(DefaultScreen(dpy));

	XSync(dpy, False);
	XSetErrorHandler(error_handler);

	config::init(confdir);
	config::read("config");
	config::fini();

	info_window::init();
	winmenu_action::init();
	menu_window::init();

	screen->init();

	pollfd fd = {};
	fd.fd = ConnectionNumber(dpy);
	fd.events = POLLIN;

	running = true;
	while (running)
	{
		while (!XPending(dpy))
		{
			if (got_alarm)
			{
				got_alarm = false;
				info_window::clear_workspace();
				XFlush(dpy);
			}

			poll(&fd, 1, -1);
		}

		union {
			XEvent x;
			XShapeEvent shape;
		} event;
		window * win;

		XNextEvent(dpy, &event.x);

		Window id = event.x.xany.window;

		if (!window::find(id, &win))
		{
			if (event.x.type == ClientMessage)
				frame_window::xclient_message(&event.x.xclient);
			continue;
		}

		switch (event.x.type)
		{
		case KeyPress:
			timestamp = event.x.xkey.time;
			win->key_press(&event.x.xkey);
			break;
		case ButtonPress:
			timestamp = event.x.xbutton.time;
			if (!pressed_button)
			{
				pressed_button = event.x.xbutton.button;
				button_moved = false;
			}
			win->button_press(&event.x.xbutton);
			break;
		case ButtonRelease:
			timestamp = event.x.xbutton.time;
			if (event.x.xbutton.button == pressed_button)
				pressed_button = 0;
			info_window::clear_frame();
			win->button_release(&event.x.xbutton);
			break;
		case MotionNotify:
			timestamp = event.x.xmotion.time;
			while (XCheckTypedWindowEvent(dpy, id, MotionNotify, &event.x)) {}
			win->motion_notify(&event.x.xmotion);
			break;
		case EnterNotify:
			timestamp = event.x.xcrossing.time;
			win->enter_notify(&event.x.xcrossing);
			break;
		case LeaveNotify:
			timestamp = event.x.xcrossing.time;
			win->leave_notify(&event.x.xcrossing);
			break;
		case FocusIn:
			win->focus_in(&event.x.xfocus);
			break;
		case FocusOut:
			win->focus_out(&event.x.xfocus);
			break;
		case Expose:
			win->expose(&event.x.xexpose);
			break;
		case DestroyNotify:
			win->destroy_notify(&event.x.xdestroywindow);
			break;
		case UnmapNotify:
			win->unmap_notify(&event.x.xunmap);
			break;
		case MapNotify:
			win->map_notify(&event.x.xmap);
			break;
		case MapRequest:
			win->map_request(&event.x.xmaprequest);
			break;
		case ConfigureNotify:
			win->configure_notify(&event.x.xconfigure);
			break;
		case ConfigureRequest:
			win->configure_request(&event.x.xconfigurerequest);
			break;
		case PropertyNotify:
			timestamp = event.x.xproperty.time;
			win->property_notify(&event.x.xproperty);
			break;
		case ClientMessage:
			win->client_message(&event.x.xclient);
			break;
		default:
			if (event.x.type != shape_event)
				break;
			timestamp = event.shape.time;
			win->shape_event(&event.shape);
		}
	}

	screen->destroy();
	XCloseDisplay(dpy);

	if (restart) execvp(argv[0], argv);

	return 0;
}
