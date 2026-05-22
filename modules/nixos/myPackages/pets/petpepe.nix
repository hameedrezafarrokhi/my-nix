{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXcursor,
  libXft,
  libXpm,
  xorgproto,
  fontconfig,
  freetype,
  pkg-config,
  gnumake,
}:

stdenv.mkDerivation rec {
  pname = "petpepe";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "Hojun-Cho";
    repo = "petpepe";
    rev = "master";
    hash = "sha256-/i+g1jzhXz6aszRCo2pA3MVI0x4gbZGwY3wBbsmuymg=";
  };

  nativeBuildInputs = [ pkg-config gnumake ];

  buildInputs = [
    libX11
    libXext
    libXcursor
    libXft
    libXpm
    xorgproto
    freetype
    fontconfig
  ];

  makeFlags = [
    "PREFIX=$out"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  buildPhase = ''
    make clean pepe
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp pepe $out/bin/pepe
  '';

  meta = with lib; {
    homepage = "https://github.com/Hojun-Cho/petpepe";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "petpepe";
  };
}
