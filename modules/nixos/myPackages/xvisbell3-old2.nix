{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxext,
  libxcomposite,
  gcc,
  xvisbellC ? ''
/* briefly flashes a colored border window to simulate a visual bell */
#define _DEFAULT_SOURCE
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/shape.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char** argv) {
	Display *display;
	Window window;
	XWindowAttributes xwa;
	unsigned long bordercolor = 0xffffff;
	char *color_hex = NULL;
	int border_width = 10;
	int duration_ms = 100;
	int start_x = 0, start_y = 0, width = 0, height = 0;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-c") == 0 && i+1 < argc) {
			color_hex = argv[++i];
			bordercolor = strtol(color_hex, NULL, 16);
		}
		else if (strcmp(argv[i], "-w") == 0 && i+1 < argc)
			border_width = atoi(argv[++i]);
		else if (strcmp(argv[i], "-d") == 0 && i+1 < argc)
			duration_ms = atoi(argv[++i]);
		else if (strcmp(argv[i], "-xs") == 0 && i+1 < argc)
			start_x = atoi(argv[++i]);
		else if (strcmp(argv[i], "-ys") == 0 && i+1 < argc)
			start_y = atoi(argv[++i]);
		else if (strcmp(argv[i], "-x") == 0 && i+1 < argc)
			width = atoi(argv[++i]);
		else if (strcmp(argv[i], "-y") == 0 && i+1 < argc)
			height = atoi(argv[++i]);
	}

	display = XOpenDisplay(NULL);
	if (!display) return 1;

	XGetWindowAttributes(display, XDefaultRootWindow(display), &xwa);
	if (width == 0) width = xwa.width - start_x;
	if (height == 0) height = xwa.height - start_y;

	window = XCreateSimpleWindow(display, XDefaultRootWindow(display),
		start_x, start_y, width, height,
		border_width, bordercolor,
		BlackPixel(display, DefaultScreen(display)));

	XSetWindowAttributes xswa;
	xswa.override_redirect = 1;
	XChangeWindowAttributes(display, window, CWOverrideRedirect, &xswa);

	/* Create shape mask - 1 = opaque, 0 = transparent */
	Pixmap mask = XCreatePixmap(display, window, width, height, 1);
	GC gc = XCreateGC(display, mask, 0, NULL);

	/* Start with everything transparent */
	XSetForeground(display, gc, 0);
	XFillRectangle(display, mask, gc, 0, 0, width, height);

	/* Make only the border area opaque */
	XSetForeground(display, gc, 1);
	for (int i = 0; i < border_width; i++) {
		XDrawRectangle(display, mask, gc,
			i, i,
			width - (i*2) - 1, height - (i*2) - 1);
	}

	XShapeCombineMask(display, window, ShapeBounding, 0, 0, mask, ShapeSet);

	XFreeGC(display, gc);
	XFreePixmap(display, mask);

	/* Map and sync */
	XMapWindow(display, window);
	XSync(display, False);

	usleep(duration_ms * 1000);

	XDestroyWindow(display, window);
	XSync(display, False);

	return 0;
}
  '',

  xvisbellM ? ''
.PHONY: all clean
CFLAGS = -std=c89 -lX11
PREFIX = $(DESTDIR)/usr/local
TARGET = xvisbell

all: $(TARGET)

$(TARGET):%:%.c
	$(CC) $< -o $@ $(CFLAGS)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -D -m 0755 -t $(PREFIX)/bin/ $^

uninstall:
	rm -f $(PREFIX)/bin/$(TARGET)

  '',

}:

stdenv.mkDerivation rec {
  pname = "xvisbell3";
  version = "2020-01-01";

  src = stdenv.mkDerivation {
    name = "xvisbell3-src";
    buildCommand = ''
      mkdir -p $out
      cat > $out/xvisbell.c <<'EOF'
      ${xvisbellC}
      EOF
      cat > $out/Makefile <<'EOF'
      ${xvisbellM}
      EOF
    '';
  };

  nuildInputs = [ gcc ];

  buildInputs = [ libx11 libxext libxcomposite ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  env.CFLAGS = "-Wall -Wextra -Werror -std=gnu99";

  buildPhase = ''
    $CC $CFLAGS -c xvisbell.c -o xvisbell.o
    $CC $CFLAGS -o xvisbell xvisbell.o $LDFLAGS -lX11 -lXcomposite -lXext
  '';

  installPhase = ''
    install -Dm755 xvisbell $out/bin/xvisbell3
  '';

  meta = {
    description = "Flash Focus For X (my fork)";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
