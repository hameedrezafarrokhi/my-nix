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
  pname = "xpickrgb";
  version = "2025-06-04";

  src = fetchurl {
    url = "https://fastestcode.org/dl/xpickrgb.tar.xz";
    hash = "sha256-jqeA08ydM6+teJ8ibQCgMcqM4FT+5RlEMUB706QBzmg=";
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
    cp xpickrgb $out/bin/
    chmod 755 $out/bin/xpickrgb
    mkdir -p $out/share/man/man1
    cp xpickrgb.1 $out/share/man/man1/
    runHook postInstall
  '';

  installTargets = [ ];

  meta = {
    homepage = "https://fastestcode.org/xpickrgb.html";
    description = "Find and Search for XFile";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
