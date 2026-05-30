{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXinerama,
  libXext,
  libXrandr,
  fontconfig,
  freetype,
  pkg-config,

  herbN ? "herbxmrv",

  herbC ? ''
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <X11/Xresource.h>
#include <X11/extensions/Xrandr.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include "config.h"

#define EXIT_ACTION 0
#define EXIT_FAIL 1
#define EXIT_DISMISS 2

#define XRES_STR(name)                                        \
if (XrmGetResource(db, "${herbN}." #name, "*", &type, &val)) \
    name = val.addr
    #define XRES_INT(name)                                        \
    if (XrmGetResource(db, "${herbN}." #name, "*", &type, &val)) \
	  name = strtoul(val.addr, 0, 10)

Display *display;
Window window;
int exit_code = EXIT_DISMISS;

static void die(const char *format, ...)
{
	va_list ap;
	va_start(ap, format);
	vfprintf(stderr, format, ap);
	fprintf(stderr, "\n");
	va_end(ap);
	exit(EXIT_FAIL);
}

int get_max_len(char *string, XftFont *font, int max_text_width)
{
	int eol = strlen(string);
	XGlyphInfo info;
	XftTextExtentsUtf8(display, font, (FcChar8 *)string, eol, &info);

	if (info.width > max_text_width)
	{
		eol = max_text_width / font->max_advance_width;
		info.width = 0;

		while (info.width < max_text_width)
		{
			eol++;
			XftTextExtentsUtf8(display, font, (FcChar8 *)string, eol, &info);
		}

		eol--;
	}

	for (int i = 0; i < eol; i++)
		if (string[i] == '\n')
		{
			string[i] = ' ';
			return ++i;
		}

	if (info.width <= max_text_width)
		return eol;

	int temp = eol;

	while (string[eol] != ' ' && eol)
		--eol;

	if (eol == 0)
		return temp;
	else
		return ++eol;
}

void expire(int sig)
{
	XEvent event;
	event.type = ButtonPress;
	event.xbutton.button = (sig == SIGUSR2) ? (ACTION_BUTTON) : (DISMISS_BUTTON);
	XSendEvent(display, window, 0, 0, &event);
	XFlush(display);
}

void read_y_offset(unsigned int **offset, int *id) {
    int shm_id = shmget(8432, sizeof(unsigned int), IPC_CREAT | 0660);
    if (shm_id == -1) die("shmget failed");

    *offset = (unsigned int *)shmat(shm_id, 0, 0);
    if (*offset == (unsigned int *)-1) die("shmat failed\n");
    *id = shm_id;
}

void free_y_offset(int id) {
    shmctl(id, IPC_RMID, NULL);
}

int main(int argc, char *argv[])
{
	if (argc == 1)
		die("Usage: %s body", argv[0]);

	struct sigaction act_expire, act_ignore;

	act_expire.sa_handler = expire;
	act_expire.sa_flags = SA_RESTART;
	sigemptyset(&act_expire.sa_mask);

	act_ignore.sa_handler = SIG_IGN;
	act_ignore.sa_flags = 0;
	sigemptyset(&act_ignore.sa_mask);

	sigaction(SIGALRM, &act_expire, 0);
	sigaction(SIGTERM, &act_expire, 0);
	sigaction(SIGINT, &act_expire, 0);

	sigaction(SIGUSR1, &act_ignore, 0);
	sigaction(SIGUSR2, &act_ignore, 0);

	if (!(display = XOpenDisplay(0)))
		die("Cannot open display");

	XrmInitialize();

	char *res_man = XResourceManagerString(display);
	XrmDatabase db = XrmGetStringDatabase(res_man);

	char *type;
	XrmValue val;

	XRES_STR(background_color);
	XRES_STR(border_color);
	XRES_STR(font_color);
	XRES_STR(font_pattern);

	XRES_INT(line_spacing);
	XRES_INT(padding);
	XRES_INT(width);
	XRES_INT(border_size);
	XRES_INT(pos_x);
	XRES_INT(pos_y);
	XRES_INT(corner);
	XRES_INT(duration);

	int screen = DefaultScreen(display);
	Visual *visual = DefaultVisual(display, screen);
	Colormap colormap = DefaultColormap(display, screen);

	int screen_x = 0;
	int screen_y = 0;
	int screen_width = DisplayWidth(display, screen);
	int screen_height = DisplayHeight(display, screen);
	if(use_primary_monitor) {
	    int nMonitors;
	    XRRMonitorInfo* info = XRRGetMonitors(display, RootWindow(display, screen), 1, &nMonitors);
	    for(int i = 0; i < nMonitors; i++) {
		  if(info[i].primary) {
			screen_x = info[i].x;
			screen_y = info[i].y;
			screen_width = info[i].width;
			screen_height = info[i].height;
		  }
	    }
	}

	XSetWindowAttributes attributes;
	attributes.override_redirect = True;
	XftColor color;
	XftColorAllocName(display, visual, colormap, background_color, &color);
	attributes.background_pixel = color.pixel;
	XftColorAllocName(display, visual, colormap, border_color, &color);
	attributes.border_pixel = color.pixel;

	int num_of_lines = 0;
	int max_text_width = width - 2 * padding;
	int lines_size = 5;
	char **lines = malloc(lines_size * sizeof(char *));
	if (!lines)
		die("malloc failed");

	XftFont *font = XftFontOpenName(display, screen, font_pattern);

	for (int i = 1; i < argc; i++)
	{
		for (unsigned int eol = get_max_len(argv[i], font, max_text_width); eol; argv[i] += eol, num_of_lines++, eol = get_max_len(argv[i], font, max_text_width))
		{
			if (lines_size <= num_of_lines)
			{
				lines = realloc(lines, (lines_size += 5) * sizeof(char *));
				if (!lines)
					die("realloc failed");
			}

			lines[num_of_lines] = malloc((eol + 1) * sizeof(char));
			if (!lines[num_of_lines])
				die("malloc failed");

			strncpy(lines[num_of_lines], argv[i], eol);
			lines[num_of_lines][eol] = '\0';
		}
	}

	int y_offset_id;
	unsigned int *y_offset;
	read_y_offset(&y_offset, &y_offset_id);

	unsigned int text_height = font->ascent - font->descent;
	unsigned int height = (num_of_lines - 1) * line_spacing + num_of_lines * text_height + 2 * padding;
	  unsigned int x = pos_x;
	  unsigned int y = pos_y + *y_offset;

	  unsigned int used_y_offset = (*y_offset) += height + padding;

	if (corner == TOP_RIGHT || corner == BOTTOM_RIGHT)
		x = screen_width - width - border_size * 2 - x;

	if (corner == BOTTOM_LEFT || corner == BOTTOM_RIGHT)
		y = screen_height - height - border_size * 2 - y;

	window = XCreateWindow(display, RootWindow(display, screen), x, y, width, height, border_size, DefaultDepth(display, screen),
						   CopyFromParent, visual, CWOverrideRedirect | CWBackPixel | CWBorderPixel, &attributes);

      XStoreName(display, window, "${herbN}");
      XClassHint class_hint;
      class_hint.res_name = "${herbN}";
      class_hint.res_class = "${herbN}";
      XSetClassHint(display, window, &class_hint);

	XftDraw *draw = XftDrawCreate(display, window, visual, colormap);
	XftColorAllocName(display, visual, colormap, font_color, &color);

	XSelectInput(display, window, ExposureMask | ButtonPress);
	XMapWindow(display, window);

	sigaction(SIGUSR1, &act_expire, 0);
	sigaction(SIGUSR2, &act_expire, 0);

	if (duration != 0)
		alarm(duration);

	for (;;)
	{
		XEvent event;
		XNextEvent(display, &event);

		if (event.type == Expose)
		{
			XClearWindow(display, window);
			for (int i = 0; i < num_of_lines; i++)
				XftDrawStringUtf8(draw, &color, font, padding, line_spacing * i + text_height * (i + 1) + padding,
								  (FcChar8 *)lines[i], strlen(lines[i]));
		}
		else if (event.type == ButtonPress)
		{
			if (event.xbutton.button == DISMISS_BUTTON)
				break;
			else if (event.xbutton.button == ACTION_BUTTON)
			{
				exit_code = EXIT_ACTION;
				break;
			}
		}
	}

	for (int i = 0; i < num_of_lines; i++)
		free(lines[i]);

	if (used_y_offset == *y_offset) free_y_offset(y_offset_id);
      free(lines);
	XftDrawDestroy(draw);
	XftColorFree(display, visual, colormap, &color);
	XftFontClose(display, font);
	XrmDestroyDatabase(db);
	XCloseDisplay(display);

	return exit_code;
}

  '',

  herbH ? ''
static const char *background_color = "#3e3e3e";
static const char *border_color = "#ececec";
static const char *font_color = "#ececec";
static const char *font_pattern = "monospace:size=10";
static unsigned line_spacing = 5;
static unsigned int padding = 15;
static const int use_primary_monitor = 0;

static unsigned int width = 450;
static unsigned int border_size = 2;
static unsigned int pos_x = 30;
static unsigned int pos_y = 60;

enum corners { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT };
enum corners corner = TOP_RIGHT;

static unsigned int duration = 5; /* in seconds */

#define DISMISS_BUTTON Button1
#define ACTION_BUTTON Button3

  '',

}:

stdenv.mkDerivation rec {
  pname = herbN;
  version = "1.0.0";

  src = stdenv.mkDerivation {
    name = "${herbN}-src";
    buildCommand = ''
      mkdir -p $out
      cat > $out/${herbN}.c <<'EOF'
      ${herbC}
      EOF
      cat > $out/config.h <<'EOF'
      ${herbH}
      EOF
    '';
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXft
    libXinerama
    libXext
    libXrandr
    fontconfig
    freetype
  ];


  buildPhase = ''
    runHook preBuild
    $CC ${herbN}.c -Wall -Wextra -pedantic \
    -I${freetype.dev}/include/freetype2_ \
    -lX11 -lXft \
    -o ${herbN} -lXrandr
    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall
    install -Dm755 ${herbN} $out/bin/${herbN}
    runHook postInstall
  '';

  meta = {
    description = "X11 Daemon-less notifications without D-Bus with Xresources,Main-Monitor,Remove-Wait,Vertical-Stack patch";
    homepage = "https://github.com/dudik/herbe";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = herbN;
  };
}
