{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXext,
  libXinerama,
  fontconfig,
  freetype,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "sara";
  version = "2019-01-01";

  src = fetchFromGitHub {
    owner = "lin-boi";
    repo = "sara";
    rev = "master";
    hash = "sha256-6OUMtw9AZu0a6kXh+OStXbaICaAcpptHFVIdFOXhRsY=";
  };

  buildInputs = [
    libX11
    libXft
    libXext
    libXinerama
    fontconfig
    freetype
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";

  makeFlags = [
    "X11INC=${libX11.dev}/include"
    "X11LIB=${libX11.dev}/lib"
    "FREETYPEINC=${freetype.dev}/include/freetype2"
    "CFLAGS=-Wall -Wno-incompatible-pointer-types"
    "BINDIR=$(out)/bin"
    "PREFIX=$(out)"
  ];

  installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/lin-boi/sara";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sara";
  };
}
