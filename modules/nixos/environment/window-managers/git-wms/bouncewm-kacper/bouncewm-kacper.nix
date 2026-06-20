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

  bouncewm-kacper-c ? ''
#include <X11/Xlib.h>
#include <unistd.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>

// change this to your terminal emulator of choice
#define TERM_PATH "/usr/bin/termite"
#define TERM "termite"

// catch BadWindow errors that occur in the main loop
// when a window exits and ignore them
// you may consider this a hack, I don't :^)
int dummy_error_handler(Display *dpy, XErrorEvent *ev) {
	return 0;
}

int main() {
	Display *dpy;
	Window root, *children = NULL, tmp_root, tmp_parent;
	XWindowAttributes attr;
	XEvent ev;
	unsigned int nchildren = 0;
	int root_width, root_height;

	if(!(dpy = XOpenDisplay(0)))
		return 1;

	root = DefaultRootWindow(dpy);

	XGetWindowAttributes(dpy, root, &attr);
	root_width = attr.width;
	root_height = attr.height;

	pid_t term_pid = fork();
	if (!term_pid) {
		execl(TERM_PATH, TERM, NULL);
	}
	assert(term_pid != -1);

	sleep(1); // give the terminal some time to spawn a window

	int *move_x = NULL,
		*move_y = NULL;

	XSetErrorHandler(dummy_error_handler);

	while(1) {
		for (unsigned int i = 0; i < nchildren; i++) {
			if (children[i]) {
				if (XGetWindowAttributes(dpy, children[i], &attr) == BadWindow)
					continue;

				int new_x = attr.x + move_x[i],
					new_y = attr.y + move_y[i];

				XMoveWindow(dpy, children[i], new_x, new_y);

				if (new_x <= 0 || (new_x + attr.width) >= root_width)
					move_x[i] = -move_x[i];

				if (new_y <= 0 || (new_y + attr.height) >= root_height)
					move_y[i] = -move_y[i];
			}
		}

		if (children)
			XFree(children);

		unsigned int new_nchildren;
		// Xorg doesn't like us giving it NULLs for root_return and parent_return
		// (IMO it should, instead it segfaults in the library), even though we don't need them
		XQueryTree(dpy, root, &tmp_root, &tmp_parent, &children, &new_nchildren);

		if (new_nchildren > nchildren) {
			move_x = realloc(move_x, new_nchildren * sizeof(int));
			move_y = realloc(move_y, new_nchildren * sizeof(int));

			for (unsigned int i = nchildren; i < new_nchildren; i++) {
				move_x[i] = 1; // right
				move_y[i] = 1; // down
			}
		}

		nchildren = new_nchildren;

		int wstatus;
		if(waitpid(term_pid, &wstatus, WNOHANG))
			return wstatus; // terminal has exitted, pass on it's return status

		usleep(16000);
	}
}

  '',

}:

gcc13Stdenv.mkDerivation rec {
  pname = "bouncewm-kacper";
  version = "none";

  src = gcc13Stdenv.mkDerivation {
    name = "bouncewm-kacper-src";
    buildCommand = ''
      mkdir -p $out
      cat > $out/bouncewm-kacper.c <<'EOF'
      ${bouncewm-kacper-c}
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
    #$CC $CFLAGS -o bouncewm-kacper bouncewm-kacper.c $LDFLAGS -lX11 -lXcomposite -lXext
    ${gcc13Stdenv.cc.targetPrefix}cc -lX11 -w -std=gnu99 -o bouncewm-kacper bouncewm-kacper.c -lX11 -lXcomposite -lXext
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bouncewm-kacper $out/bin/bouncewm-kacper
  '';

  meta = with lib; {
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bouncewm-kacper";
  };
}
