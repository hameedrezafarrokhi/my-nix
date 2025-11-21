{
  lib,
  stdenv,
  fetchgit,
  xorgproto,
  libX11,
  libXft,
  customConfig ? null,
  patches ? [ ],

}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tabbed";
  #version = "0.9";

  src = fetchgit {
    url = "https://github.com/bakkeby/tabbed-flexipatch";
    rev = "master";
    hash = "sha256-IpFbkyNNzMtESjpQNFOUdE6Tl+ezJN85T71Cm7bqlj2=";
  };

  inherit patches;

  postPatch = lib.optionalString (customConfig != null) ''
    cp ${builtins.toFile "config.h" customConfig} ./config.h
  '';

  buildInputs = [
    xorgproto
    libX11
    libXft
  ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/bakkeby/tabbed-flexipatch";
    description = "Simple generic tabbed fronted to xembed aware applications";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };

})
