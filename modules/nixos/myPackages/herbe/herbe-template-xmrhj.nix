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
  json_c,

  herbN ? "herbxmrhj",

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
//history patch
#include <time.h>
#include <sys/stat.h>
#include <errno.h>
#include <json-c/json.h>

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

//history patch
void save_to_history(char **lines, int num_of_lines)
{
    const char *history_dir = "/.local/share/herbe";
    char home_dir[1024];
    char history_path[2048];
    time_t now;
    struct tm *tm_info;

    char *home = getenv("HOME");
    if (!home) return;

    snprintf(home_dir, sizeof(home_dir), "%s/.local/share/herbe", home);
    mkdir(home_dir, 0777);

    snprintf(history_path, sizeof(history_path), "%s/history.json", home_dir);

    char current_msg[4096] = {0};
    for (int i = 0; i < num_of_lines; i++) {
        strcat(current_msg, lines[i]);
        if (i < num_of_lines - 1) strcat(current_msg, " ");
    }

    json_object *existing_array = json_object_from_file(history_path);
    if (!existing_array) {
        existing_array = json_object_new_array();
    }

    int array_len = json_object_array_length(existing_array);
    if (array_len > 0) {
        json_object *last_entry = json_object_array_get_idx(existing_array, array_len - 1);
        int match = 1;

        for (int i = 0; i < num_of_lines; i++) {
            char key[16];
            snprintf(key, sizeof(key), "message%d", i + 1);
            json_object *last_msg = json_object_object_get(last_entry, key);

            if (!last_msg || strcmp(lines[i], json_object_get_string(last_msg)) != 0) {
                match = 0;
                break;
            }
        }

        if (match) {
            int last_msg_count = 0;
            json_object_object_foreach(last_entry, key, val) {
                if (strncmp(key, "message", 7) == 0) last_msg_count++;
            }
            if (last_msg_count == num_of_lines) {
                json_object_put(existing_array);
                return;
            }
        }
    }

    if (array_len >= MAX_HISTORY_LINES) {
        json_object_array_del_idx(existing_array, 0, 1);
        array_len--;
    }

    time(&now);
    tm_info = localtime(&now);

    json_object *new_entry = json_object_new_object();
    json_object_object_add(new_entry, "year", json_object_new_int(tm_info->tm_year + 1900));
    json_object_object_add(new_entry, "month", json_object_new_int(tm_info->tm_mon + 1));
    json_object_object_add(new_entry, "day", json_object_new_int(tm_info->tm_mday));
    json_object_object_add(new_entry, "hour", json_object_new_int(tm_info->tm_hour));
    json_object_object_add(new_entry, "minute", json_object_new_int(tm_info->tm_min));
    json_object_object_add(new_entry, "second", json_object_new_int(tm_info->tm_sec));

    for (int i = 0; i < num_of_lines; i++) {
        char key[16];
        snprintf(key, sizeof(key), "message%d", i + 1);
        json_object_object_add(new_entry, key, json_object_new_string(lines[i]));
    }

    json_object_array_add(existing_array, new_entry);

    json_object_to_file_ext(history_path, existing_array, JSON_C_TO_STRING_PRETTY);
    json_object_put(existing_array);
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

	unsigned int x = screen_x + pos_x;
	unsigned int y = screen_y + pos_y;
	unsigned int text_height = font->ascent - font->descent;
	unsigned int height = (num_of_lines - 1) * line_spacing + num_of_lines * text_height + 2 * padding;

	if (corner == TOP_RIGHT || corner == BOTTOM_RIGHT)
		x = screen_x + screen_width - width - border_size * 2 - pos_x;

	if (corner == BOTTOM_LEFT || corner == BOTTOM_RIGHT)
		y = screen_y + screen_height - height - border_size * 2 - pos_y;

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

      //history patch
      save_to_history(lines, num_of_lines);

	for (int i = 0; i < num_of_lines; i++)
		free(lines[i]);

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
#define MAX_HISTORY_LINES 500

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
    json_c
  ];


  buildPhase = ''
    runHook preBuild
    $CC ${herbN}.c -Wall -Wextra -pedantic \
    -I${freetype.dev}/include/freetype2_ \
    -lX11 -lXft -ljson-c \
    -o ${herbN} -lXrandr
    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall
    install -Dm755 ${herbN} $out/bin/${herbN}
    runHook postInstall
  '';

  meta = {
    description = "X11 Daemon-less notifications without D-Bus with Xresources,Main-Monitor,Remove-Wait patch";
    homepage = "https://github.com/dudik/herbe";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = herbN;
  };
}
