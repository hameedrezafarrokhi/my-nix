{
  lib,
  stdenv,
  pkg-config,
  libX11,
  libXext,
  libXcursor,
  libXi,
  libXrender,
  libXfixes,
  libXrandr,
  librsvg,
  cairo,
  withSvg ? true,
}:

stdenv.mkDerivation rec {
  pname = "cursor-scaler";
  version = "1.0.0";

  # This file lives at nix/default.nix inside the project; build from the
  # project root so the Makefile and src/ tree are visible.
  src = ../.;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXext
    libXcursor
    libXi
    libXrender
    libXfixes
    libXrandr
  ] ++ lib.optionals withSvg [
    librsvg
    cairo
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ] ++ lib.optionals (!withSvg) [ "NO_RSVG=1" ];

  installFlags = [ "DESTDIR=" ];

  meta = {
    homepage = "https://github.com/adelmonte/x11_shake_to_magnify_cursor";
    description = "Shake-to-magnify cursor for X11, with lossless SVG zoom and no-compositor support";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "cursor-scaler";
  };
}
