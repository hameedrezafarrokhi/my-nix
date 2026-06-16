{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXinerama,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "goomwwm";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "seanpringle";
    repo = "goomwwm";
   #rev = "master";
    rev = "5747442e8842e8b150e75f656dec4b2db225110f";
    sha256 = "1nmqkdkw1vhk7wjvvngsnpi30czgs2hlhagl338c1jaclv1px39b";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libX11
    libXft
    libXinerama
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp goomwwm $out/bin/goomwwm
  '';

  meta = {
    homepage = "http://www.github.com/seanpringle/goomwwm";
    description = " ";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
  };
}
