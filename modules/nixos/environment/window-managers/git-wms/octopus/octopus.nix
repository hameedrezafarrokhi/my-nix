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

  writeText,
  conf ? null,
  conf2 ? null,

  flex,
  bison,
  byacc,
  autoconf,
  automake,
  libtool,
  #m4,
  cairo,
  gtk2-x11,
  gtk2,
  libxxf86vm,
  gdk-pixbuf-xlib,
}:

stdenv.mkDerivation rec {
  pname = "octopus-window-manager";
  version = "2026-06-19";

  src = fetchFromGitHub {
    owner = "ghjp";
    repo = "octopus-window-manager";
   #rev = "master";
    rev = "e9ac5272e2208f1adf0209b6be4cb9db7c550785";
    sha256 = "0yps45xhh6zc6cgn02cpr9xy7wmkvb0wjpbarxvwhjs6lm6nmp5y";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.xml.in" conf;
      configFile2 =
        if lib.isDerivation conf2 || builtins.isPath conf2 then conf2 else writeText "xkeyb.xml.in" conf2;
    in
    lib.optionalString (conf != null) "cp ${configFile} examples/config.xml.in"
    + " \n " +
    lib.optionalString (conf2 != null) "cp ${configFile2} examples/xkeyb.xml.in"
    ;


  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    #m4
    flex
    bison
    byacc
    cairo
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

    gtk2
    gtk2-x11
    libxxf86vm
    gdk-pixbuf-xlib
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
  ];

  preConfigure = ''
    # Regenerate build system
    #autoupdate
    #aclocal
    #automake --foreign --add-missing
    autoconf --force
    autoreconf -vfi
  '';

  meta = with lib; {
    homepage = "https://github.com/ghjp/octopus-window-manager";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "octopus-window-manager";
  };
}
