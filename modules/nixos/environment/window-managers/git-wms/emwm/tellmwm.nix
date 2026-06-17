{
  lib,
  stdenv,
  fetchurl,
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
}:

stdenv.mkDerivation rec {
  pname = "tellmwm";
  version = "2026-06-14";

  src = fetchurl {
    url = "https://fastestcode.org/dl/tellmwm-src.tar.xz";
    hash = "sha256-+05H1n2gwr6ZyVrO307XKXtwiIzu7Ru9ojaQOVL80nA=";
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
    mkdir -p $out/share/man/man1
    cp tellmwm $out/bin/
    cp tellmwm.1 $out/share/man/man1/
    chmod 755 $out/bin/tellmwm
    runHook postInstall
  '';

  installTargets = [ ];

  meta = {
    homepage = "https://fastestcode.org/emwm.html";
    description = "cli for emwm";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
