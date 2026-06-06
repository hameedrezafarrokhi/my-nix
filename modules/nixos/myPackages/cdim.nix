{
  lib,
  gcc,
  stdenv,
  fetchFromGitHub,
  libXrender,
  libXcomposite,
  libX11,
}:

stdenv.mkDerivation rec {
  pname = "cDim";
  version = "2025.01.01";

  src = fetchFromGitHub {
    owner = "wolandark";
    repo = "cDim";
    rev = "master";
    hash = "sha256-AQ+y1hZqLjddrai6IqLNl5QtCeXz4Bies13w5e+KgFk=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [
    libXrender
    libXcomposite
    libX11
  ];

  buildPhase = ''
    $CC -o cdim main.c -lX11 -lXrender -lXcomposite
  '';

  installPhase = ''
    install -Dm755 cdim $out/bin/cdim
  '';

  meta = {
    homepage = "https://github.com/wolandark/cDim";
    description = "";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
