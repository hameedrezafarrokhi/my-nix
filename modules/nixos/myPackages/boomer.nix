{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libGL,
  pkg-config,
  gcc,
  nim-1_0,
  libGLU,
  freeglut,
}:

let

  x11-nim = fetchFromGitHub {
    owner = "nim-lang";
    repo = "x11";
    rev = "3dd8f523fb2b502f4e5a958d8acf09a0b8ac0452";
    sha256 = "0zaarwii6h3njl96kwrv8ag3hfy60lyw2x5dg37fdplhkywdic66";
  };
  opengl-nim = fetchFromGitHub {
    owner = "nim-lang";
    repo = "opengl";
    rev = "f51db493faca670576afffe2117d59b80f934394";
    sha256 = "1k3nxad0q74nynxi4l21ix9jwn5w1gpvpgynzp9v90x22n3k85hb";
  };

in

stdenv.mkDerivation (finalAttrs: {
  pname = "boomer";
  version = "2026-06-01";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "boomer";
    rev = "master";
    hash = "sha256-GxrPoDU1vj0SGuji/vinRu7WThY/J7LTdIdrOG4WOwo=";
  };

  naviteBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    nim-1_0
    libX11
    libXext
    libXrandr
    libGL
    libGLU
    freeglut
  ];

  buildPhase = ''
    HOME=$TMPDIR
    nim -p:${x11-nim}/ -p:${opengl-nim}/src c -d:release src/boomer.nim
  '';

  installPhase = "install -Dt $out/bin src/boomer";

  fixupPhase = "patchelf --set-rpath ${lib.makeLibraryPath [stdenv.cc.cc libX11 libXrandr libGL]} $out/bin/boomer";

  meta = {
    description = "boomer x zoomer";
    homepage = "https://github.com/tsoding/boomer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "boomer";
  };
})
