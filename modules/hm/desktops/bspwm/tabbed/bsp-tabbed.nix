{ lib
, stdenv
, fetchFromGitHub
, xorgproto
, libX11
, libXft
, customConfig ? null
, patches ? [ ]
}:

stdenv.mkDerivation {

  name = "tabbed-flexipatch";

  src = ./flexipatch;

  inherit patches;

  postPatch = lib.optionalString (customConfig != null) ''
    cp ${builtins.toFile "config.h" customConfig} ./config.h
  '';

  buildInputs = [
    xorgproto
    libX11
    libXft
  ];

  makeFlags = [ "CC=cc" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/bakkeby/tabbed-flexipatch";
    description = "Tabbed build with flexible patches for tabbed (suckless)";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
