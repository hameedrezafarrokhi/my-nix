{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxext,
  libxscrnsaver,
}:

stdenv.mkDerivation rec {
  pname = "xidle";
  version = "2021-01-01";

  src = fetchFromGitHub {
    owner = "mjml";
    repo = "xidle";
    rev = "main";
    hash = "sha256-c0ay1442LizdUUG+wLXlossHPuesN5GoF1cEKqkm0FE=";
  };

  buildInputs = [
    libx11
    libxext
    libxscrnsaver
  ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    mkdir -p $out/bin
    cp xidle $out/bin/
  '';

  meta = {
    homepage = "https://github.com/mjml/xidle";
    description = "Prints X Server Idle Time To stdout";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
