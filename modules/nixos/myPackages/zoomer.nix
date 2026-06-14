{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libGL,
  glew,
  pkg-config,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "zoomer";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "laluxx";
    repo = "zoomer";
    rev = "main";
    hash = "sha256-Nv2TVTsFbb5vkbwtQ4JhLici8TclpIogAUJtlMkAn1U=";
  };

  naviteBuildInputs = [
    pkg-config
    gcc
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$out"
   #"DESTDIR=$out"
   #"SYSCONFDIR=$out/etc"
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libGL
    glew
  ];

  installPhase = ''
    install -Dm755 zoomer $out/bin/zoomer
    mkdir -p $out/etc/zoomer
    install -Dm644 vert.glsl $out/etc/zoomer/vert.glsl
    install -Dm644 frag.glsl $out/etc/zoomer/frag.glsl
  '';

  postInstall = ''
    wrapProgram $out/bin/zoomer \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = {
    description = "zoomer x boomer c port";
    homepage = "https://github.com/laluxx/zoomer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "zoomer";
  };
}
