{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  libx11,
  libxt,
  libxext,
  libxinerama,
  libxrandr,
  libxrender,
  libxcursor,
  libxcomposite,
  libxft,
  libxkbcommon,
  libxpm,
  libxres,
  libxmu,
  libxmi,
  libxmp,
  xorgproto,
  libjpeg_turbo,
  libpng,
  libtiff,
  motif,
  gcc,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "xmdialog";
  version = "2026-06-04";

  src = fetchurl {
    url = "https://fastestcode.org/dl/xmdialog-src.tar.xz";
    hash = "sha256-ZpImKWMa0QECWz0gbtcOpYu28TNNVW6bfUyB5OC1DZ4=";
  };

  buildInputs = [
    libx11
    libxt
    libxext
    libxinerama
    libxrandr
    libxrender
    libxcursor
    libxcomposite
    libxft
    libxkbcommon
    libxpm
    libxres
    libxmu
    libxmi
    libxmp
    xorgproto
    libjpeg_turbo
    libpng
    libtiff
    motif
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp xmdialog $out/bin/
    chmod 755 $out/bin/xmdialog
    mkdir -p $out/share/man/man1
    cp xmdialog.1 $out/share/man/man1/
    runHook postInstall
  '';

  installTargets = [ ];

  meta = {
    homepage = "https://fastestcode.org/xmdialog.html";
    description = "Find and Search for XFile";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
