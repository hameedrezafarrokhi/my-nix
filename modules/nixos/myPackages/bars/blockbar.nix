{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,
  libpkgconf,
  pkgconf,

  cairo,
  pango,

  wayland,
  wayland-protocols,
  libGL,
  libGLX,
  egl-x11,
  egl-wayland,

}:

stdenv.mkDerivation rec {
  pname = "blockbar";
  version = "2025-10-12";

  src = fetchFromGitHub {
    owner = "sambazley";
    repo = "blockbar";
   #rev = "main";
    rev = "b51b0bb293539024593149a5501241390bb21026";
    sha256 = "0ihgcs4ifd7jcqgiwqsvkm1q594cajqfwwl0cln3k905glrdvxym";
  };

  nativeBuildInputs = [
    pkg-config
    cairo
    cairo.dev
    libpkgconf
    pkgconf
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype

    cairo
    cairo.dev
    pango

    wayland
    wayland-protocols
    libGL
    libGLX
    egl-x11
    egl-wayland
  ];

  prePatch = ''
    substituteInPlace src/config.h \
      --replace '#include "types.h"' '  '
    substituteInPlace src/config.h \
      --replace '#include <ujson.h>' '  '
    substituteInPlace src/blockbar.c \
      --replace '#include <ujson.h>' '  '
  '';

  preBuild = ''
    export PKG_CONFIG_PATH="${cairo.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    "CFLAGS+=-I${cairo.dev}/include/cairo"
    "LDLIBS+=-L${cairo.out}/lib -lcairo"
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp blockbar $out/bin/blockbar
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/sambazley/blockbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "blockbar";
  };
}
