{
  lib,
  stdenv,
  fetchFromGitea,
  libx11,
  libxcursor,
  pkg-config,
  writeText,
  conf ? null,
 #conf ? ''
 #  #include <X11/Xlib.h>
 #  #include <X11/Xcursor/Xcursor.h>
 #
 #  int main(void)
 #  {
 #      Display *dpy = XOpenDisplay(NULL);
 #      if (!dpy)
 #          return 1;
 #
 #      Window root = DefaultRootWindow(dpy);
 #
 #      // Load cursor from the current theme
 #      XcursorImage *image = XcursorLibraryLoadImage("left_ptr", NULL, 32);
 #      if (!image) {
 #          XCloseDisplay(dpy);
 #          return 1;
 #      }
 #
 #      Cursor cursor = XcursorImageLoadCursor(dpy, image);
 #      XcursorImageDestroy(image);
 #
 #      XDefineCursor(dpy, root, cursor);
 #      XFlush(dpy);
 #
 #      XFreeCursor(dpy, cursor);
 #      XCloseDisplay(dpy);
 #
 #      return 0;
 #  }
 #'',
}:

stdenv.mkDerivation rec {
  pname = "xsetcursor";
  version = "2026-07-02";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "LukaBregadze";
    repo = "xsetcursor";
    rev = "de32e4dc4cef53342d806d0bb75270ed90844486";
    sha256 = "0cjfm22h7a5fjwgn3z3zk7dj37j65pk6l101lxavm3b30rgarz5i";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "xsetcursor.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} xsetcursor.c";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
    libxcursor
  ];

  buildPhase = ''
    runHook preBuild

    gcc -o xsetcursor xsetcursor.c -lX11 -lXcursor

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp xsetcursor $out/bin/xsetcursor

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/LukaBregadze/xsetcursor";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xsetcursor";
  };
}
