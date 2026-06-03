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

  herbN ? "herbxmd",

  herbC ? ''
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <X11/Xresource.h>
#include <X11/extensions/Xrandr.h>
#include <X11/Xatom.h>

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <semaphore.h>

#include "config.h"

#define EXIT_ACTION 0
#define EXIT_FAIL 1
#define EXIT_DISMISS 2

#define HERBE_UPDATE "HERBE_UPDATE"
#define HERBE_TEXT   "HERBE_TEXT"

Display *display;
Window window;
int exit_code = EXIT_DISMISS;

static void die(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n");
    va_end(ap);
    exit(EXIT_FAIL);
}

static void expire(int sig) {
    XEvent ev;
    ev.type = ClientMessage;
    ev.xclient.message_type = XInternAtom(display, HERBE_UPDATE, False);
    ev.xclient.window = window;
    ev.xclient.format = 32;
    XSendEvent(display, window, False, 0, &ev);
    XFlush(display);
}

static int get_max_len(char *string, XftFont *font, int max_width) {
    int eol = strlen(string);
    XGlyphInfo info;

    XftTextExtentsUtf8(display, font, (FcChar8 *)string, eol, &info);

    if (info.width > max_width) {
        eol = max_width / font->max_advance_width;
        info.width = 0;

        while (info.width < max_width && string[eol]) {
            eol++;
            XftTextExtentsUtf8(display, font, (FcChar8 *)string, eol, &info);
        }
        eol--;
    }

    while (eol > 0 && string[eol] != ' ')
        eol--;

    return (eol == 0) ? strlen(string) : eol + 1;
}

static void rebuild(char *text,
                    char ***lines,
                    int *nlines,
                    int *height,
                    XftFont *font,
                    int width,
                    int padding,
                    int line_spacing,
                    int text_width)
{
    for (int i = 0; i < *nlines; i++)
        free((*lines)[i]);
    free(*lines);

    int cap = 8;
    *lines = malloc(cap * sizeof(char *));
    *nlines = 0;

    char *copy = strdup(text);
    char *p = copy;

    while (*p) {
        if (*nlines >= cap) {
            cap += 8;
            *lines = realloc(*lines, cap * sizeof(char *));
        }

        int len = get_max_len(p, font, text_width);
        (*lines)[(*nlines)] = strndup(p, len);
        (*nlines)++;

        p += len;
    }

    int line_h = font->ascent + font->descent;
    *height = (*nlines * line_h) + ((*nlines - 1) * line_spacing) + 2 * padding;

    free(copy);
}

int main(int argc, char *argv[]) {
    if (argc < 2)
        die("usage: ${herbN} <text>");

    char *text = argv[1];

    struct sigaction act;
    act.sa_handler = expire;
    sigemptyset(&act.sa_mask);
    act.sa_flags = SA_RESTART;
    sigaction(SIGALRM, &act, NULL);

    if (!(display = XOpenDisplay(NULL)))
        die("cannot open display");

    int screen = DefaultScreen(display);
    Visual *visual = DefaultVisual(display, screen);
    Colormap colormap = DefaultColormap(display, screen);

    XSetWindowAttributes attr;
    attr.override_redirect = True;

    XftColor bg, fg;
    XftColorAllocName(display, visual, colormap, background_color, &bg);
    XftColorAllocName(display, visual, colormap, font_color, &fg);
    attr.background_pixel = bg.pixel;

    XftFont *font = XftFontOpenName(display, screen, font_pattern);

    int num_lines = 0;
    char **lines = NULL;

    int text_width = width - 2 * padding;
    int height = 0;

    rebuild(text, &lines, &num_lines, &height, font,
             width, padding, line_spacing, text_width);

    int screen_w = DisplayWidth(display, screen);
    int screen_h = DisplayHeight(display, screen);

    int x = pos_x;
    int y = pos_y;

    window = XCreateWindow(display, RootWindow(display, screen),
                           x, y, width, height, border_size,
                           DefaultDepth(display, screen),
                           CopyFromParent, visual,
                           CWOverrideRedirect | CWBackPixel, &attr);

    XStoreName(display, window, "${herbN}");

    Atom update_atom = XInternAtom(display, HERBE_UPDATE, False);
    Atom text_atom   = XInternAtom(display, HERBE_TEXT, False);

    XSelectInput(display, window, ExposureMask | ButtonPress);
    XMapWindow(display, window);

    alarm(duration);

    while (1) {
        XEvent ev;
        XNextEvent(display, &ev);

        if (ev.type == Expose) {
            XClearWindow(display, window);
            XftDraw *draw = XftDrawCreate(display, window, visual, colormap);

            for (int i = 0; i < num_lines; i++) {
                XftDrawStringUtf8(draw, &fg, font,
                                  padding,
                                  (i + 1) * (font->ascent + font->descent + line_spacing),
                                  (FcChar8 *)lines[i],
                                  strlen(lines[i]));
            }

            XftDrawDestroy(draw);
        }

        else if (ev.type == ButtonPress) {
            if (ev.xbutton.button == Button1)
                break;
        }

        else if (ev.type == ClientMessage &&
                 ev.xclient.message_type == update_atom) {

            Atom actual;
            int format;
            unsigned long nitems, bytes;
            char *newtext = NULL;

            if (XGetWindowProperty(display, window, text_atom,
                                   0, 4096, False, AnyPropertyType,
                                   &actual, &format,
                                   &nitems, &bytes,
                                   (unsigned char **)&newtext) == Success
                && newtext) {

                rebuild(newtext, &lines, &num_lines, &height,
                        font, width, padding,
                        line_spacing, text_width);

                XResizeWindow(display, window, width, height);

                XFree(newtext);
            }

            alarm(duration);
            XClearWindow(display, window);
        }
    }

    for (int i = 0; i < num_lines; i++)
        free(lines[i]);
    free(lines);

    XftFontClose(display, font);
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
    -lX11 -lXft -pthread \
    -o ${herbN} -lXrandr
    runHook postBuild
  '';


  installPhase = ''
    runHook preInstall
    install -Dm755 ${herbN} $out/bin/${herbN}
    runHook postInstall
  '';

  meta = {
    description = "X11 Daemon-less notifications without D-Bus with Xresources,Main-Monitor,Dynamic-Text patch";
    homepage = "https://github.com/dudik/herbe";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = herbN;
  };
}
