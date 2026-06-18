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
  nim,
  glib,
  libGLU,
  freeglut,
  egl-x11,
  makeWrapper,
  autoPatchelfHook,
  zlib,
}:

stdenv.mkDerivation rec {

  pname = "boomer-bin";
  version = "2026-06-18";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "959ddcbd9d697dc7b817161ac3dc6ff66c961898";
    sha256 = "1a7akwgrf7r9cjkwxnkni7wmdzg14l18p1bpr8xgr78fxxhv0my0";
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
  ];

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/boomer/boomer $out/bin/boomer
  '';

  installPhase = ''
    wrapProgram $out/bin/boomer \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/boomer || true
  '';

  meta = {
    description = "boomer x zoomer";
    homepage = "https://github.com/tsoding/boomer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "boomer";
  };
}
