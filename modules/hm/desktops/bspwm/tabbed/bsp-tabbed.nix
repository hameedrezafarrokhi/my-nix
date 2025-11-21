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

 #src = fetchFromGitHub {
 #  owner = "bakkeby";
 #  repo = "tabbed-flexipatch";
 #  rev = "77d8b71540791d5593c841cdb7160d4feb23a8fe";  # commit hash
 #  sha256 = "sha256-Imh+kMOEWhtuET0MWrT6HJ+rPLWvbiz4cQPxGDYN3cQ=";
 #};

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
