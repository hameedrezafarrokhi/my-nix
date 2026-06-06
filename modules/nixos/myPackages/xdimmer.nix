{
  lib,
  stdenv,
  fetchFromGitHub,
  libXrandr,
  libXext,
  libX11,
  libXi,
  libXfixes,
  libbsd,
}:

stdenv.mkDerivation rec {
  pname = "xdimmer";
  version = "2024.01.01";

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "xdimmer";
    rev = "master";
    hash = "sha256-wRq7ps7Pc0HIknbc2rTvt+qQzNU0IdC7Qds1EahDSZE=";
  };

  buildInputs = [
    libXrandr
    libXext
    libX11
    libXi
    libXfixes
    libbsd
  ];

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=$(out)"
  ];

  meta = {
    homepage = "https://github.com/jcs/xdimmer";
    description = "";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
