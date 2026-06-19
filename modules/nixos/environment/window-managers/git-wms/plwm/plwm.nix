{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxft,
  libxrandr,
  freetype,
  fontconfig,
  pkg-config,
  swi-prolog,
}:

stdenv.mkDerivation rec {
  pname = "plwm";
  version = "2026-04-13";

  src = fetchFromGitHub {
    owner = "Seeker04";
    repo = "plwm";
   #rev = "main";
    rev = "8744d22bf6cf4e1abd520921eacce1fe38277741";
    sha256 = "05qfcxhz8m399skm7jk0348561722kgwgpqs5gk351i6sb0phglf";
  };

  nativeBuildInputs = [
    pkg-config
    swi-prolog
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    freetype
    fontconfig
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
    "CFLAGS=-std=c99 -I${swi-prolog}/lib/swipl/include -I${freetype}/include/freetype2 -Wall -Wextra -Wconversion -Wshadow -pedantic -pedantic-errors -O2 -fpic"
    "LDFLAGS=-shared -lX11 -lXft -lXrandr"
    #"LIB_PATH =${placeholder "out"}/lib"
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p bin
    make ${builtins.concatStringsSep " " makeFlags}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp bin/plwm $out/bin/
    cp bin/plx.so $out/lib/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Seeker04/plwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "plwm";
  };
}
