{
  lib,
  stdenv,
  fetchurl,
  libX11,
  libXext,
  libXrandr,
  libGL,
  pkg-config,
  gcc,
  nim,
  glib,
  libGLU,
  freeglut,
  egl-x11,
  makeWrapper,
  autoPatchelfHook,
  zlib,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  SDL2_Pango,
}:

stdenv.mkDerivation rec {

  pname = "nimlaunch";
  version = "2026-07-03";

  src = fetchurl {
    url = "https://codeberg.org/Vyrnexis/NimLaunch/releases/download/v0.10.1/nimlaunch";
    hash = "sha256-SI0rSb8APYQkPMzGUkfwpHcZPoWsRqr+29Uq5lDO0AI=";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

  buildInputs = [
    zlib
    libX11
    libXext
    libXrandr
    libGL
    libGLU
    freeglut
    glib
    egl-x11
    SDL2_Pango
    SDL2_image
    SDL2_ttf
    SDL2
  ];

  dontUnpack = true;

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/nimlaunch $out/bin/
  '';

  installPhase = ''
    wrapProgram $out/bin/nimlaunch \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/nimlaunch || true
  '';

  meta = {
    description = "NimLaunch x zoomer";
    homepage = "https://codeberg.org/Vyrnexis/NimLaunch";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "NimLaunch";
  };
}
