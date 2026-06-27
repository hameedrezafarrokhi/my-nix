{
  lib,
  stdenv,
 #fetchurl,
  fetchFromGitHub,
  libX11,
  libXext,
  libxcomposite,
  libxft,
  libxpm,
  autoconf,
  autoreconfHook,
  gettext,
  automake,
  libtool,
  libsm,
  freetype,
  fontconfig,
  pkg-config,
  writeText,
  fltk,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "flwm";
 #version = "1.02";
 #version = "1.00";
  version = "1.6";

 #src = fetchurl {
 #  url = "https://flwm.sourceforge.net/flwm-${version}.tgz";
 #  hash = "sha256-BXBoHWj3q4hz46hexIyupeRWlxsiLlbV1hWrRuPLBHg=";
 #};

 #src = fetchurl {
 #  url = "https://flwm.sourceforge.net/flwm-${version}-x86.tgz";
 #  hash = "sha256-g6tjX68tgCla9FLCK44MtrOT7gc9Orxcpk139kOXaaQ=";
 #};

 #src = ./flwm;

  src = fetchFromGitHub {
    owner = "bbidulock";
    repo = "flwm";
   #rev = "master";
   #tag = version;
    rev = "02904d90ace8901e49cbe073a1ddce181903d1c8";
    sha256 = "19qk2z5xwlx600lcwp9x95yzar5fmh8myq9ljhk4mhscl16f6zyg";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  nativeBuildInputs = [
    libtool
    autoconf
    autoreconfHook
    gettext
    automake
    pkg-config
    fltk
  ];

  buildInputs = [
    libX11
    libXext
    libxcomposite
    libxft
    libxpm
    autoconf
    gettext
    automake
    libtool
    libsm
    fontconfig
    freetype
    fltk
  ];

 #dontBuild = true;
 #doCheck = false;

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" ];

  buildPhase = ''
    runHook preBuild
    ./configure --prefix=/usr
    make
    runHook postBuild
  '';

 #installPhase = ''
 #  mkdir -p $out/bin
 #  cp flwm $out/bin/flwm
 #'';

  installPhase = ''
    mkdir -p $out/bin
    cp flwm $out/bin/
    mkdir -p $out/share/man/man1
    cp flwm.1 $out/share/man/man1/
  '';

  meta = with lib; {
    homepage = "http://flwm.sourceforge.net/";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "flwm";
  };
}
