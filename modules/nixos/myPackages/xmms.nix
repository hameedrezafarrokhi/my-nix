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
  gtk3,
  gettext,
  libmikmod,
  libGL,
  egl-x11,
  libvorbis,
  libogg,
  zlib,

  autoconf,
  automake,
  libtool,
  cairo,
 #gtk2-x11,
 #gtk2,
  gdk-pixbuf-xlib,

  glib,
  ...
}:

stdenv.mkDerivation rec {
  pname = "xmms";
  version = "2018-12-08";

  src = fetchFromGitHub {
    owner = "deepfire";
    repo = "xmms";
   #rev = "master";
    rev = "5847897230da018d93cd9833695f944ece96587b";
    sha256 = "035vkxc5himczxv4fpxyfna0yzsxn72g947bsafhq2xbycp3bs3q";
  };

  nativeBuildInputs = [
    pkg-config
    glib
    autoconf
    automake
    libtool
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

    gtk3
    gettext
    libmikmod
    libGL
    egl-x11
    libvorbis
    libogg
    zlib

    autoconf
    automake
    libtool
    cairo
   #gtk2-x11
   #gtk2
    gdk-pixbuf-xlib

    glib
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
   #"CFLAGS+=' -fno-tree-slp-vectorize'"
   #"CFLAGS+=' -std=gnu89'"
  ];

 #env = {
 # #NIX_CFLAGS_COMPILE = "-Wno-implicit-int -std=gnu11";
 #  "CFLAGS+"="' -std=gnu89'";
 #  "CFLAGS+"="' -fno-tree-slp-vectorize'";
 #};

  buildPhase = ''
    runHook preBuild

    #autoupdate --force
    ./configure --prefix=$out --disable-static
    #autoreconf -vfi
    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make install

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/deepfire/xmms";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xmms";
  };
}
