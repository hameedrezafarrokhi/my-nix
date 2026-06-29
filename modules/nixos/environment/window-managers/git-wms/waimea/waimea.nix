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
  imlib2Full,

  autoconf,
  automake,
  libtool,
  bash,
  installShellFiles,

}:

stdenv.mkDerivation rec {
  pname = "waimea";
  version = "2015-10-25";

  src = fetchFromGitHub {
    owner = "bbidulock";
    repo = "waimea";
   #rev = "master";
    rev = "f1fda114febbacad5ca187ab23eae48b46253916";
    sha256 = "0hn606n473yf1clbkfyqpklwvssg167kqsf98nxsqcbyazfrghf0";
  };

  prePatch = ''
    substituteInPlace autogen.sh \
      --replace '#!/bin/bash' '#!/usr/bin/env bash'

    substituteInPlace configure.sh \
      --replace '#!/bin/bash' '#!/usr/bin/env bash'

    substituteInPlace rebuild.sh \
      --replace '#!/bin/bash' '#!/usr/bin/env bash'
  '';

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    bash
    installShellFiles
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

    imlib2Full
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    ./autogen
    ./configure --prefix=/usr --enable-shape --enable-xinerama \
        --enable-render --enable-randr --enable-xft \
        --enable-pixmap &&
    make
    make install

    #automake --foreign --add-missing
    #autoreconf -vfi

    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  #mkdir -p $out/bin
 #  #cp waimea $out/bin/waimea
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/bbidulock/waimea";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "waimea";
  };
}
