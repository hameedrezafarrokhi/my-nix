{
  lib,
  stdenv,
 #fetchurl,
  fetchFromGitHub,
  imake,
  gccmakedep,
  libX11,
  libXext,
  libXmu,
}:

stdenv.mkDerivation rec {
  pname = "larswm";
  version = "2014-10-20";

 #src = fetchurl {
 #  url = "mirror://sourceforge/larswm/larswm-${version}.tar.gz";
 #  sha256 = "1xmlx9g1nhklxjrg0wvsya01s4k5b9fphnpl9zdwp29mm484ni3v";
 #};

  src = fetchFromGitHub {
    owner = "bbidulock";
    repo = "larswm";
   #rev = "master";
    rev = "efa957cebafeb6810754566a47569ac6cc8fdd6e";
    sha256 = "1y5xm4p5vicdysc2v535ig0j0hisg8gjyqm7514i52c93igwqgp2";
  };

  nativeBuildInputs = [
    imake
    gccmakedep
  ];
  buildInputs = [
    libX11
    libXext
    libXmu
  ];

  makeFlags = [
    "BINDIR=$(out)/bin"
    "MANPATH=$(out)/share/man"
  ];
  installTargets = [
    "install"
    "install.man"
  ];

  meta = {
    homepage = "http://www.fnurt.net/larswm";
    description = "9wm-like tiling window manager";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
  };
}
