{
  lib,
  gcc,
  stdenv,
  fetchFromGitHub,
  libXrender,
  libXcomposite,
  libX11,
  cdimC ? ''
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/extensions/Xrender.h>
#include <X11/extensions/Xcomposite.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void usage(const char *prog) {
    fprintf(stderr,
        "Usage: %s [options]\n"
        "  -xs <x>      Window X position\n"
        "  -ys <y>      Window Y position\n"
        "  -x <width>   Window width\n"
        "  -y <height>  Window height\n"
        "  -d <0-100>   Dim percentage (0=transparent, 100=opaque)\n"
        "  -c <hex>     Dim color (RRGGBB)\n"
        "  -n <name>    Window name\n"
        "  -k <key>     Close key (example: q)\n",
        prog
    );
}

int main(int argc, char **argv) {
    Display *display;
    Window root, win;
    XEvent ev;
    XRenderPictFormat *pictformat;
    XRenderPictureAttributes pa;
    Picture picture;
    Atom atomWmDeleteWindow;

    int screen;

    int win_x = 100;
    int win_y = 100;
    int win_width = 400;
    int win_height = 300;
    int focusable = 0;

    int dim_percent = 50;
    char *wm_name = "Dimming Window";
    char close_key[32] = "q";

    unsigned int color_rgb = 0x000000;

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-xs") && i + 1 < argc) {
            win_x = atoi(argv[++i]);
        } else if (!strcmp(argv[i], "-ys") && i + 1 < argc) {
            win_y = atoi(argv[++i]);
        } else if (!strcmp(argv[i], "-x") && i + 1 < argc) {
            win_width = atoi(argv[++i]);
        } else if (!strcmp(argv[i], "-y") && i + 1 < argc) {
            win_height = atoi(argv[++i]);
        } else if (!strcmp(argv[i], "-d") && i + 1 < argc) {
            dim_percent = atoi(argv[++i]);
            if (dim_percent < 0) dim_percent = 0;
            if (dim_percent > 100) dim_percent = 100;
        } else if (!strcmp(argv[i], "-c") && i + 1 < argc) {
            color_rgb = (unsigned int)strtoul(argv[++i], NULL, 16);
        } else if (!strcmp(argv[i], "-n") && i + 1 < argc) {
            wm_name = argv[++i];
        }  else if (!strcmp(argv[i], "-f")) {
            focusable = 1;
        } else if (!strcmp(argv[i], "-k") && i + 1 < argc) {
            strncpy(close_key, argv[++i], sizeof(close_key) - 1);
            close_key[sizeof(close_key) - 1] = '\0';
        } else {
            usage(argv[0]);
            return 1;
        }
    }

    display = XOpenDisplay(NULL);
    if (!display)
        return 1;

    screen = DefaultScreen(display);
    root = RootWindow(display, screen);

    int event_base, error_base;
    if (!XCompositeQueryExtension(display, &event_base, &error_base)) {
        fprintf(stderr, "Composite extension not supported.\n");
        return 1;
    }

    int render_event_base, render_error_base;
    if (!XRenderQueryExtension(display, &render_event_base, &render_error_base)) {
        fprintf(stderr, "Render extension not supported.\n");
        return 1;
    }

    XVisualInfo vinfo;
    if (!XMatchVisualInfo(display, screen, 32, TrueColor, &vinfo)) {
        fprintf(stderr, "No 32-bit TrueColor visual found.\n");
        return 1;
    }

    XSetWindowAttributes attr;
    attr.colormap = XCreateColormap(display, root, vinfo.visual, AllocNone);
    attr.border_pixel = 0;
    attr.background_pixel = 0;
    // attr.override_redirect = True;
    attr.override_redirect = !focusable;

    win = XCreateWindow(
        display,
        root,
        win_x,
        win_y,
        win_width,
        win_height,
        0,
        vinfo.depth,
        InputOutput,
        vinfo.visual,
        CWColormap | CWBorderPixel | CWBackPixel,
        &attr
    );

    if (!focusable) {
        XWMHints *wmh = XAllocWMHints();
        if (wmh) {
            wmh->flags = InputHint;
            wmh->input = False;
            XSetWMHints(display, win, wmh);
            XFree(wmh);
        }
    }

    XClassHint class_hint;
    class_hint.res_name = "cdim";
    class_hint.res_class = "cdim";
    XSetClassHint(display, win, &class_hint);

    XSizeHints hints;
    hints.flags = PPosition | PSize;
    hints.x = win_x;
    hints.y = win_y;
    hints.width = win_width;
    hints.height = win_height;
    XSetWMNormalHints(display, win, &hints);

    atomWmDeleteWindow = XInternAtom(display, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(display, win, &atomWmDeleteWindow, 1);

    XStoreName(display, win, wm_name);

    XSelectInput(
        display,
        win,
        ExposureMask |
        KeyPressMask |
        ButtonPressMask |
        StructureNotifyMask
    );

    XMapWindow(display, win);

    XMoveResizeWindow(display,
                      win,
                      win_x,
                      win_y,
                      win_width,
                      win_height);
    XFlush(display);

    pictformat = XRenderFindVisualFormat(display, vinfo.visual);
    if (!pictformat) {
        fprintf(stderr, "No render format found for visual.\n");
        return 1;
    }

    pa.subwindow_mode = IncludeInferiors;
    picture = XRenderCreatePicture(
        display,
        win,
        pictformat,
        CPSubwindowMode,
        &pa
    );

    XRenderColor clear_color = {0, 0, 0, 0};

    unsigned short r = ((color_rgb >> 16) & 0xFF) * 257;
    unsigned short g = ((color_rgb >> 8) & 0xFF) * 257;
    unsigned short b = (color_rgb & 0xFF) * 257;
    unsigned short a = (unsigned short)((65535ULL * dim_percent) / 100);

    XRenderColor dim_color = {
        r,
        g,
        b,
        a
    };

    KeySym close_keysym = XStringToKeysym(close_key);

    while (1) {
        XNextEvent(display, &ev);

        if (ev.type == Expose || ev.type == ConfigureNotify) {
            if (ev.type == ConfigureNotify) {
                win_width = ev.xconfigure.width;
                win_height = ev.xconfigure.height;
            }

            XRenderFillRectangle(
                display,
                PictOpSrc,
                picture,
                &clear_color,
                0,
                0,
                win_width,
                win_height
            );

            XRenderFillRectangle(
                display,
                PictOpOver,
                picture,
                &dim_color,
                0,
                0,
                win_width,
                win_height
            );
        }

        if (ev.type == KeyPress) {
            KeySym pressed =
                XLookupKeysym(&ev.xkey, 0);

            if (pressed == close_keysym)
                break;
        }

        if (ev.type == ClientMessage &&
            (Atom)ev.xclient.data.l[0] == atomWmDeleteWindow) {
            break;
        }
    }

    XRenderFreePicture(display, picture);
    XDestroyWindow(display, win);
    XCloseDisplay(display);

    // printf("%d %d %d %d\n",
    //         win_x, win_y,
    //         win_width, win_height);

    return 0;
}
  '',
}:

stdenv.mkDerivation rec {
  pname = "cDim";
  version = "2025.01.01";

 #src = fetchFromGitHub {
 #  owner = "wolandark";
 #  repo = "cDim";
 #  rev = "master";
 #  hash = "sha256-AQ+y1hZqLjddrai6IqLNl5QtCeXz4Bies13w5e+KgFk=";
 #};

  src = stdenv.mkDerivation {
    name = "cdim-src";
    buildCommand = ''
      mkdir -p $out
      cat > $out/main.c <<'EOF'
      ${cdimC}
      EOF
    '';
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [
    libXrender
    libXcomposite
    libX11
  ];

  buildPhase = ''
    $CC -o cdim main.c -lX11 -lXrender -lXcomposite
  '';

  installPhase = ''
    install -Dm755 cdim $out/bin/cdim
  '';

  meta = {
    homepage = "https://github.com/wolandark/cDim";
    description = "";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
