{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  fontconfig,
  libX11,
  libXcursor,
  libXext,
  libXrender,
  libXft,
  freetype,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "iguassu";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "gboncoffee";
    repo = "iguassu";
    rev = "master";
    hash = "sha256-JSv5Mu9IsY3TreESYuvXQUcacSYlM9zPl/+T1UYCNPo=";
  };

  nativeBuildInputs = [
    gcc
  ];

  buildInputs = [
    fontconfig
    libX11
    libXcursor
    libXext
    libXrender
    libXft
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    freetype
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  CC = "gcc";
  CFLAGS = "-Wall -g";
  LIBS = "";
  CLIBS = "-lfontconfig -lXft -lX11 -lX11-xcb -lxcb -lxcb-res";

  buildPhase = ''
    $CC $CFLAGS $INCS $LIBS -o iguassu iguassu.c $CLIBS
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp iguassu $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/gboncoffee/iguassu";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "iguassu";
  };
}
