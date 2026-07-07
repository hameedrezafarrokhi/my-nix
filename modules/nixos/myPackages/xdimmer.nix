{
  lib,
  gcc13Stdenv,
  fetchFromGitHub,
  libXrandr,
  libXext,
  libX11,
  libXi,
  libXfixes,
  libbsd,
  libfixposix,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "xdimmer";
  version = "v1.6";

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "xdimmer";
   #rev = "master";
    tag = version;
   #hash = "sha256-wRq7ps7Pc0HIknbc2rTvt+qQzNU0IdC7Qds1EahDSZE=";
    hash = "sha256-WfI88aydt2TMxh+Fr4cjnvND0pN42esH6i6Q7ZPOveI=";
  };

  buildInputs = [
    libXrandr
    libXext
    libX11
    libXi
    libXfixes
    libbsd
    libfixposix
  ];

  makeFlags = [
    "CC=${gcc13Stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #  #${gcc13Stdenv.cc.targetPrefix}cc -O2 -Wall -Wunused -Wmissing-prototypes -Wstrict-prototypes -Wunused -I/usr/X11R6/include -c xdimmer.c -o xdimmer.o
 #  ${gcc13Stdenv.cc.targetPrefix}cc -O2 -w -I/usr/X11R6/include -c xdimmer.c -o xdimmer.o
 #
 #  runHook postBuild
 #'';

  meta = {
    homepage = "https://github.com/jcs/xdimmer";
    description = "";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
