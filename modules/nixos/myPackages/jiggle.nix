{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  libX11,
  libXext,
  libXcursor,
  libXi,
  libXrender,
  libXfixes,
  libXrandr,
  pkg-config,

#  src-c ? ''
##include <X11/Xlib.h>
##include <X11/Xcursor/Xcursor.h>
##include <stdbool.h>
##include <stdio.h>
##include <stdlib.h>
##include <unistd.h>
#
#typedef struct Pos {
#  int x, y, dx, dy;
#  struct Pos *next;
#} Pos;
#
##define MAX_POS 24
##define MAX_DELTA 400
#
#static Pos Poss[MAX_POS];
#
#bool isJiggled() {
#  int changeNumX = 0;
#  int max_x = Poss[0].x, min_x = Poss[0].x, max_y = Poss[0].y,
#      min_y = Poss[0].y;
#
#  for (int i = 0; i < MAX_POS; i++) {
#    if ((Poss[i].dx > 0 && Poss[i].next->dx < 0) ||
#        (Poss[i].dx < 0 && Poss[i].next->dx > 0)) {
#      changeNumX++;
#    }
#
#    if (Poss[i].x > max_x)
#      max_x = Poss[i].x;
#    if (Poss[i].x < min_x)
#      min_x = Poss[i].x;
#    if (Poss[i].y > max_y)
#      max_y = Poss[i].y;
#    if (Poss[i].y < min_y)
#      min_y = Poss[i].y;
#  }
#
#  return changeNumX > 2 && (max_x - min_x < MAX_DELTA) &&
#         (max_y - min_y < MAX_DELTA / 2);
#}
#
#int main() {
#  Display *disp;
#  Window root_window;
#  int screen;
#  Pos *index = &Poss[0];
#  Pos *prev = &Poss[MAX_POS - 1];
#
#  for (int i = 0; i < MAX_POS; i++) {
#    Poss[i].next = &Poss[(i + 1) % MAX_POS];
#    Poss[i].x = 0;
#    Poss[i].y = 0;
#    Poss[i].dx = 0;
#    Poss[i].dy = 0;
#  }
#
#  disp = XOpenDisplay(NULL);
#  if (disp == NULL) {
#    fprintf(stderr, "无法打开X显示\n");
#    return 1;
#  }
#
#  screen = DefaultScreen(disp);
#  root_window = RootWindow(disp, screen);
#
#  Window child_window;
#  int win_x, win_y;
#  unsigned int mask;
#
#  while (1) {
#    bool result = XQueryPointer(disp, root_window, &child_window, &child_window,
#                                &index->x, &index->y, &win_x, &win_y, &mask);
#
#    if (result) {
#      index->dx = index->x - prev->x;
#      index->dy = index->y - prev->y;
#
#      if (isJiggled()) {
#        XcursorSetTheme(disp, "default");
#        XcursorSetDefaultSize(disp, 70);
#        usleep(30000);
#      } else {
#        XcursorSetTheme(disp, "default");
#        XcursorSetDefaultSize(disp, 24);
#      }
#
#      prev = index;
#    }
#
#    index = index->next;
#
#    usleep(10000);
#  }
#
#  XCloseDisplay(disp);
#
#  return 0;
#}
#  '',

  src-c ? ''
#include <X11/Xlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct Pos {
  int x, y, dx, dy;
  struct Pos *next;
} Pos;

#define MAX_POS 24
#define MAX_DELTA 400

static Pos Poss[MAX_POS];

bool isJiggled() {
  int changeNumX = 0;
  int max_x = Poss[0].x, min_x = Poss[0].x, max_y = Poss[0].y,
      min_y = Poss[0].y;

  for (int i = 0; i < MAX_POS; i++) {
    if ((Poss[i].dx > 0 && Poss[i].next->dx < 0) ||
        (Poss[i].dx < 0 && Poss[i].next->dx > 0)) {
      changeNumX++;
    }

    if (Poss[i].x > max_x)
      max_x = Poss[i].x;
    if (Poss[i].x < min_x)
      min_x = Poss[i].x;
    if (Poss[i].y > max_y)
      max_y = Poss[i].y;
    if (Poss[i].y < min_y)
      min_y = Poss[i].y;
  }

  return changeNumX > 2 && (max_x - min_x < MAX_DELTA) &&
         (max_y - min_y < MAX_DELTA / 2);
}

int main() {
  Display *disp;
  Window root_window;
  int screen;
  Pos *index = &Poss[0];
  Pos *prev = &Poss[MAX_POS - 1];

  for (int i = 0; i < MAX_POS; i++) {
    Poss[i].next = &Poss[(i + 1) % MAX_POS];
    Poss[i].x = 0;
    Poss[i].y = 0;
    Poss[i].dx = 0;
    Poss[i].dy = 0;
  }

  disp = XOpenDisplay(NULL);
  if (disp == NULL) {
    fprintf(stderr, "无法打开X显示\n");
    return 1;
  }

  screen = DefaultScreen(disp);
  root_window = RootWindow(disp, screen);

  Window child_window;
  int win_x, win_y;
  unsigned int mask;

  while (1) {
    bool result = XQueryPointer(disp, root_window, &child_window, &child_window,
                                &index->x, &index->y, &win_x, &win_y, &mask);

    if (result) {
      index->dx = index->x - prev->x;
      index->dy = index->y - prev->y;

      if (isJiggled()) {
        system("cursor 140");
        usleep(30000);
      } else {
        system("cursor 24");
      }

      prev = index;
    }

    index = index->next;

    usleep(10000);
  }

  XCloseDisplay(disp);

  return 0;
}
  '',
}:

stdenv.mkDerivation rec {
  pname = "jiggle";
  version = "2024-01-01";

  src = stdenv.mkDerivation {
    name = "jiggle-src";
    buildCommand = ''
      mkdir -p $out
      cat > $out/jiggle.c <<'EOF'
      ${src-c}
      EOF
    '';
  };

 #src = fetchFromGitHub {
 #  owner = "adelmonte";
 #  repo = "jiggle";
 #  rev = "master";
 #  hash = "sha256-AAAAXwPnBcDJcSICSxagrpIVWuPSBsJcjGTUPdoGrbI=";
 #};

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXext
    libXcursor
    libXi
    libXrender
    libXfixes
    libXrandr
  ];

  buildPhase = ''
    $CC -o jiggle jiggle.c -lX11 -lXcursor -lXrender -lXfixes -lXrandr -lXi -Wall -O2
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp jiggle $out/bin/
  '';

  meta = {
    homepage = "https://github.com/luo216/jiggle";
    description = "shake to magnify cursor for x11";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
