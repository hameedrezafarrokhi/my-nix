{
  lib,
  stdenv,
  fetchFromGitHub,
  flex,
  bison,

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

  libxau,

  makeWrapper,
  gcc,

  imake,
}:

stdenv.mkDerivation rec {
  pname = "solbourne-wm";
  version = "2024-10-01";

  src = fetchFromGitHub {
    owner = "MagnetarRocket";
    repo = "Solbourne-WM";
   #rev = "master";
    rev = "722c818a5e3954265cb396fe407566906ae4ebb1";
    hash = "sha256-gWdmnf6K3PjXQCHWZPreyYf6n5Bhm2NdzsL1Y6B4VGM=";
  };

  sourceRoot = "source/swm";

  nativeBuildInputs = [
    flex
    bison
    makeWrapper
    pkg-config
    imake
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

    libxau
  ];

  buildPhase = ''
    runHook preBuild

    imake

    runHook postBuild
  '';

  # The original build uses Imake, but we'll use a custom Makefile
  # since Imake is complex to set up for this old code
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
   #"CFLAGS=-I${libx11.dev}/include -I${libxext.dev}/include -I${libxt.dev}/include -I${libxmu.dev}/include"
   #"LDFLAGS=-L${libx11.out}/lib -L${libxext.out}/lib -L${libxt.out}/lib -L${libxmu.out}/lib -lX11 -lXext -lXt -lXmu"
  ];
 #
 #preBuild = ''
 #  # Generate lex and yacc files
 #  flex -t lex.L > lex.C
 #  bison -d gram.Y
 #  #mv gram.tab.c gram.C
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  # Install binary
 #  install -Dm755 swm $out/bin/swm
 #
 #  # Install config files
 #  mkdir -p $out/share/X11/swm
 #  cp -r config/* $out/share/X11/swm/
 #
 #  # Install man pages
 #  mkdir -p $out/share/man/man1
 #  cp man/swm.man $out/share/man/man1/swm.1
 #
 #  # Install utilities
 #  for util in swmcmd swmhints ssetroot; do
 #    if [ -d "$util" ]; then
 #      (cd "$util" && make && install -Dm755 "$util" $out/bin/"$util")
 #    fi
 #  done
 #
 #  runHook postInstall
 #'';
 #
 ## Create a wrapper to set the config path
 #postInstall = ''
 #  wrapProgram $out/bin/swm \
 #    --set SWM_CONFIG_PATH $out/share/X11/swm
 #'';

  meta = with lib; {
    description = "Solbourne Window Manager - a virtual desktop window manager from 1993";
    longDescription = ''
      swm (Solbourne Window Manager) is a window manager for X11 that features:
      - Virtual desktop support
      - Configurable look and feel through X resources
      - Panel buttons on root window
      - Primitive session management
      - External command interface (swmcmd)

      NOTE: This is very old software (1993) and requires the Object Interface (OI) toolkit.
      This package attempts to build it without OI, but may not work correctly.
      The original version required OI which is no longer maintained.
    '';
    homepage = "https://github.com/MagnetarRocket/Solbourne-WM";
    maintainers = with maintainers; [ ];
  };
}
