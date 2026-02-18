{ lib
, stdenv
, fetchFromGitHub
, bash
, coreutils
, gawk
, xwininfo
, xprop
, xdotool
, bspwm
, tabbed
}:

stdenv.mkDerivation rec {
  pname = "bsptab";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "albertored11";
    repo  = "bsptab";
    rev   = "0.2";
    sha256 = "sha256-G2GZKnrb9QIcnsGizIut8w6utfEobVquh4UJkGCrzAc=";
  };

  buildInputs = [
    bash
    coreutils
    gawk
    xwininfo
    xprop
    xdotool
    bspwm
    tabbed
  ];

  installPhase = ''
    mkdir -p $out
    make PREFIX=$out install
  '';

  meta = with lib; {
    description = "Tabbed container integration scripts for bspwm";
    homepage = "https://github.com/username/bsptab"; # update
    license = licenses.mit; # AUR says "AUR license"; update if necessary
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
