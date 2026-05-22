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
}:

stdenv.mkDerivation rec {
  pname = "xpet-with-config";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "BITchCreateShitWare";
    repo = "xpet-with-config";
    rev = "master";
    hash = "sha256-AY91tAiq5pZ4KwYbZk99z8CZ/NqXbmpzJFh0KYZkxyQ=";
  };

  nativeBuildInputs = [ pkg-config ];

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

  buildPhase = ''
    runHook preBuild
    ${stdenv.cc}/bin/cc -o xpet ./experimental/xpet.c -lX11 -lXext -lXpm $(pkg-config --cflags --libs freetype2) -Wall -Wextra
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp xpet $out/bin/xpet-with-config
    chmod 755 $out/bin/xpet-with-config
    mkdir -p $out/share/xpet-with-config
    cp -r pets $out/share/xpet-with-config/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/BITchCreateShitWare/xpet-with-config";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xpet-with-config";
  };
}
