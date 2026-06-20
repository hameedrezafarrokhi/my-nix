{
  lib,
  gcc13Stdenv,
  gcc13,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

  bouncewm-c ? ''
#include <X11/Xlib.h>
#include <unistd.h>

int main()
{
    Window root;
    Display * dpy;
    XWindowAttributes attr;
    XEvent ev;

    if(!(dpy = XOpenDisplay(0x0))) return 1;

    root = DefaultRootWindow(dpy);

    XGrabButton(dpy, 1, Mod1Mask, root, True, ButtonPressMask, GrabModeAsync,
            GrabModeAsync, None, None);
    int right = 1;
    int up = 1;
    int x = 0;
    int y = 0;
    for(;;)
    {
        XNextEvent(dpy, &ev);
        if(ev.type == ButtonPress && ev.xbutton.subwindow != None)
        {
            XGetWindowAttributes(dpy, ev.xbutton.subwindow, &attr);
            x = 40;
            y = 40;
            for(;;) {
                XMoveWindow(dpy, ev.xbutton.subwindow, x, y);
                XSync(dpy, 0);
                if (x > 1280 - attr.width) {
                    right = 0;
                } else if (x < 0) {
                    right = 1;
                }

                if (y < 0) {
                    up = 1;
                } else if (y > 800 - attr.height) {
                    up = 0;
                }

                x += (right == 1) ? 8 : -6;
                y += (up == 1) ? 6 : -4;
                usleep(50 * 1000);
            }
        }
    }
}


  '',

#  bouncewm-m ? ''
#.PHONY: all clean
#CFLAGS = -std=c99 -lX11
#PREFIX = $(DESTDIR)/usr/local
#TARGET = bouncewm-src
#
#all: $(TARGET)
#
#$(TARGET):%:%.c
#	$(CC) $< -o $@ $(CFLAGS)
#
#clean:
#	rm -f $(TARGET)
#
#install: $(TARGET)
#	install -D -m 0755 -t $(PREFIX)/bin/ $^
#
#uninstall:
#	rm -f $(PREFIX)/bin/$(TARGET)
#
#  '',

}:

gcc13Stdenv.mkDerivation rec {
  pname = "bouncewm";
  version = "none";

  src = gcc13Stdenv.mkDerivation {
    name = "bouncewm-src";
    buildCommand = ''
      mkdir -p $out
      cat > $out/bouncewm.c <<'EOF'
      ${bouncewm-c}
      EOF
    '';
  };

  nativeBuildInputs = [
    pkg-config
    gcc13
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
  ];

 #makeFlags = [ "CC=${gcc13Stdenv.cc.targetPrefix}cc" ];

 #installFlags = [ "PREFIX=${placeholder "out"}" ];

 #env.CFLAGS = "-Wall -Wextra -Werror -std=gnu99";

  buildPhase = ''
    #$CC $CFLAGS -o bouncewm bouncewm.c $LDFLAGS -lX11 -lXcomposite -lXext
    ${gcc13Stdenv.cc.targetPrefix}cc -Os -pedantic -Wall -o bouncewm bouncewm.c -lX11 -lXcomposite -lXext
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bouncewm $out/bin/bouncewm
  '';

  meta = with lib; {
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bouncewm";
  };
}
