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
  pname = "xfile";
  version = "1.2.0";

  src = fetchurl {
    url = "https://fastestcode.org/dl/xfile-src-${version}.tar.xz";
    hash = "sha256-x7ycxfaoNPANRnCLNFYM4OaCLw1L6kIWkR5X+Psjc5c=";
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
    ln -sf ../mf/Makefile.Linux src/Makefile
    make -C src
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    cp src/xfile $out/bin/
    cp src/xfile.1 $out/share/man/man1/
    chmod 755 $out/bin/xfile
    runHook postInstall
  '';

  installTargets = [ ];

  meta = {
    homepage = "https://fastestcode.org/xfile.html";
    description = "Image Viewer";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
