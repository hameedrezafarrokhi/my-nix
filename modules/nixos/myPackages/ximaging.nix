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
  xorgproto,
  libjpeg_turbo,
  libpng,
  libtiff,
  motif,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "ximaging";
  version = "1.9.1";

  src = fetchurl {
    url = "https://fastestcode.org/dl/ximaging-src-${version}.tar.xz";
    hash = "sha256-zBAzvaE0D37EmjQmg+enj+AEwH64y1JMgu7+w+pYYY8=";
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
    cp src/ximaging $out/bin/
    cp src/ximaging.1 $out/share/man/man1/
    chmod 755 $out/bin/ximaging
    runHook postInstall
  '';

  installTargets = [ ];

  meta = {
    homepage = "https://fastestcode.org/ximaging.html";
    description = "Image Viewer";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
