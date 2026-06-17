{ lib
, stdenv
, fetchurl
, autoconf
, automake
, libtool
, m4
, libXpm
, libXmu
, libXft
, libXinerama
, libXrandr
, libX11
, libXt
, libXext
, libXrender
, libxkbfile
, xorgproto
, flex
, bison
, byacc
, writeText
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "vtwm";
  version = "5.5.0";

  src = fetchurl {
    url = "https://sourceforge.net/projects/vtwm/files/${pname}-${version}.tar.gz";
    hash = "sha256-RI16/Y1aX8+r8bnGS4Ec+mvb+IksBn/gGhQYBu9h6vQ=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    m4
    xorgproto
    flex
    bison
    byacc
    pkg-config
  ];

  buildInputs = [
    libXpm
    libXmu
    libXft
    libXinerama
    libXrandr
    libX11
    libXt
    libXext
    libXrender
    libxkbfile
  ];

  preConfigure = ''
    # Fix missing includes
    sed -i '/prototypes.h/a #include <time.h>' add_window.c
    sed -i '/prototypes.h/a #include <sys/wait.h>' menus.c

    # Regenerate build system
    autoupdate
    aclocal
    automake --foreign --add-missing
    autoconf --force
  '';

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--sysconfdir=/etc"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-int -std=gnu11";

  installPhase = ''
    make install
  '';

  meta = with lib; {
    description = "A lightweight, customizable window manager with a virtual desktop";
    homepage = "http://www.vtwm.org";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    mainProgram = "vtwm";
  };
}
