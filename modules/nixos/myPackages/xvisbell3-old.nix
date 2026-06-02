{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  gcc,
  xvisbellC ? ''
/* briefly flashes a colored border window to simulate a visual bell */
#define _DEFAULT_SOURCE
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char** argv) {
	Display *display;
	Window  window;
	XWindowAttributes xwa;
	XSetWindowAttributes xswa;
	unsigned long bordercolor = 0xffffff;
	char *color_hex = NULL;
	int border_width = 10;
	int duration_ms = 100;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-c") == 0 && i+1 < argc) {
			color_hex = argv[++i];
			bordercolor = strtol(color_hex, NULL, 16);
		}
		else if (strcmp(argv[i], "-w") == 0 && i+1 < argc) {
			border_width = atoi(argv[++i]);
		}
		else if (strcmp(argv[i], "-d") == 0 && i+1 < argc) {
			duration_ms = atoi(argv[++i]);
		}
	}

	display = XOpenDisplay(NULL);
	if (!display) return 1;

	XGetWindowAttributes(display, XDefaultRootWindow(display), &xwa);

	window = XCreateSimpleWindow(display, XDefaultRootWindow(display),
		0, 0,
		xwa.width, xwa.height,
		border_width, bordercolor,
		0x0);

	xswa.override_redirect = 1;
	xswa.background_pixel = 0x0;
	XChangeWindowAttributes(display, window,
		CWOverrideRedirect | CWBackPixel, &xswa);

	XClassHint class_hint;
	class_hint.res_name = "visualbell";
	class_hint.res_class = "VisualBell";
	XSetClassHint(display, window, &class_hint);

	XStoreName(display, window, "visualbell");
	XSetIconName(display, window, "visualbell");

	XMapWindow(display, window);
	XFlush(display);

	usleep(duration_ms * 1000);

	XDestroyWindow(display, window);
	XFlush(display);

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

  buildInputs = [ libx11 ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  env.CFLAGS = "-Wall -Wextra -Werror -std=gnu99";

  buildPhase = ''
    $CC $CFLAGS -c xvisbell.c -o xvisbell.o
    $CC $CFLAGS -o xvisbell xvisbell.o $LDFLAGS -lX11
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
