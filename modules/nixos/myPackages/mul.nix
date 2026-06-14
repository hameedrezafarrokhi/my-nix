{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libGL,
  pkg-config,
  clang,
}:

stdenv.mkDerivation rec {
  pname = "mul";
  version = "2026-05-01";

  src = fetchFromGitHub {
    owner = "kaif-c";
    repo = "mul";
    rev = "main";
    hash = "sha256-n429PpKE+cl8uyznOPPMzb/p7aj2//Jqv80zopodEgU=";
  };

  naviteBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libGL
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp build/dbg/mul $out/bin/mul
  '';

 #postInstall = ''
 #  wrapProgram $out/bin/mul \
 #    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
 #'';

  meta = {
    description = "zoomer x mul c port";
    homepage = "https://github.com/kaif-c/mul";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "mul";
  };
}
