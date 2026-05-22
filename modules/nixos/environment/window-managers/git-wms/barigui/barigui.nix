{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  fontconfig,
  libX11,
  libXrender,
  libXext,
  libXft,
  libXcursor,
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
  pname = "barigui";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "gboncoffee";
    repo = "barigui";
    rev = "master";
    hash = "sha256-XzLveCng7hzC8G7mgoHY6ozahw4lbiye5RcmNPwjoXQ=";
  };

  nativeBuildInputs = [
    gcc
  ];

  buildInputs = [
    fontconfig
    libX11
    libXext
    libXft
    libXcursor
    libXrender
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

 #makeFlags = [
 #  "CC=gcc"
 #  "INCS=-I${freetype.dev}/include/freetype2 -I${libX11.dev}/include -I${libXft}/include -I${fontconfig}/include"
 #  "LIBS=-L${libX11.out}/lib -L${libXft}/lib -L${fontconfig.out}/lib -L${freetype.out}/lib"
 #];

  installPhase = ''
    mkdir -p $out/bin
    cp barigui $out/bin/
  '';

 #installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/gboncoffee/barigui";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "barigui";
  };
}
