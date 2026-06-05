{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  pkg-config,
  libxcb,
  libxcb-util,
  libxcb-image,
  libxcb-wm,
  libxcb-keysyms,
  libGL,
  libXft,
  libXrender,
  libXrandr,
  libXext,
  libXres,
  fontconfig,
  libX11,
  libXinerama,
  mesa,
}:

stdenv.mkDerivation rec {
  pname = "choyce";
 #version = "2020-01-01";
  version = "2013.12.13";

  src = fetchFromGitHub {
    owner = "jchnkl";
    repo = "x-choyce";
    tag = version;
    hash = "sha256-JgmwFI56hNE5nsoeadcn6KJFt57gnKRiNwfnR9c3q0Y=";

   #rev = "master";
   #hash = "sha256-PL5BzXgTF3lo4X64FP6EOuyGELjf5reB56wKHq37jcQ=";
  };

  nativeBuildInputs = [ pkg-config gcc ];

  buildInputs = [
    libxcb
    libxcb-util
    libxcb-image
    libxcb-wm
    libxcb-keysyms
    libGL
    libXft
    libXrender
    libXrandr
    libXext
    libXres
    fontconfig
    libX11
    libXinerama
    mesa
  ];

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=$(out)"
    "CFLAGS=-Wno-error"
  ];

  installPhase = ''
    runHook preInstall
    make install PREFIX=$out
    mkdir -p $out/share/x:choyce/shaders
    cp -r src/shaders/* $out/share/x:choyce/shaders/
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/jchnkl/x-choyce";
    description = "Nyancat";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
