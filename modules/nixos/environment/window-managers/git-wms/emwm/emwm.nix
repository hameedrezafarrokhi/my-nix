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
  fetchzip,
}:

let

  extra-icons = fetchzip {
    url = "https://fastestcode.org/dl/app-icons.tar.xz";
    hash = "sha256-hu9YB/bE0LWkdOfuNQAwxBjuvp5mZMWM4jy8FgablTs=";
    stripRoot = true;
  };

  cursors = fetchzip {
    url = "https://fastestcode.org/dl/xc-core-hr.tar.xz";
    hash = "sha256-2Z9fdT7JWu2emL/vYXRvAOmtKOeI6Guw52xXNdF+cYc=";
    stripRoot = true;
  };

  bitmaps = fetchzip {
    url = "https://fastestcode.org/dl/xc-core-hr.tar.xz";
    hash = "sha256-2Z9fdT7JWu2emL/vYXRvAOmtKOeI6Guw52xXNdF+cYc=";
    stripRoot = true;
  };

in

stdenv.mkDerivation rec {
  pname = "emwm";
  version = "2.0";

  src = fetchurl {
    url = "https://fastestcode.org/dl/emwm-src-${version}.tar.xz";
    hash = "sha256-8E+IdLR6Mnn6Aq2QJkaydpOFAVGM5Q9XUehf5ggftjA=";
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
    cp src/emwm $out/bin/
    cp src/emwm.1 $out/share/man/man1/
    chmod 755 $out/bin/emwm

    mkdir -p $out/share/emwm/icons
    mkdir -p $out/share/emwm/cursors
    mkdir -p $out/share/emwm/bitmaps
    cp -r ${extra-icons}/* $out/share/emwm/icons/
    cp -r ${cursors}/* $out/share/emwm/cursors/
    cp -r ${bitmaps}/* $out/share/emwm/bitmaps/

    runHook postInstall
  '';

  installTargets = [ ];

  meta = {
    homepage = "https://fastestcode.org/emwm.html";
    description = "Image Viewer";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
