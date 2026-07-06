{
  lib,
  stdenv,
  fetchFromGitea,
  fetchFromGitHub,
  buildNimPackage,
  nim1,
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
}:

let

  drawim = fetchFromGitHub {
    owner = "GabrielLasso";
    repo = "drawim";
    tag = "0.1.3";
    hash = "sha256-NUXOBld0znlvOhuqCKy0+tiXOuSgYZ5tsH84Q+pny/E=";
  };

in

stdenv.mkDerivation (finalAttrs: {
  pname = "clonk";
  version = "2023-03-17";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "pswilde";
    repo = "Clonk";
    rev = "4ae73f0a85d4f626787236aea9909ea860304605";
    sha256 = "1a34rch4knmhxpw7mn5mdfkbss9md3rpg0dh6v4z7jhvdmlvvzd4";
  };

  nativeBuildInputs = [
    pkg-config
    nim1
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

  buildPhase = ''
    HOME=$TMPDIR
    nim --run -p:${drawim}/src/:${drawim}/ c -d:release src/clonk.nim
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp clonk $out/bin/clonk
  '';

  meta = {
    description = " ";
    homepage = "https://codeberg.org/pswilde/Clonk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "clonk";
    platforms = lib.platforms.linux;
  };
})
