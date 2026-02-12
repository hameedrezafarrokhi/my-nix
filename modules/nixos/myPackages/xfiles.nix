{
  lib,
  stdenv,
  fetchFromGitHub,
  imlib2Full,
  libX11,
  libXft,
  libXinerama,
  fontconfig,
  freetype,
  libXext,
  libXcursor,
  libXrender,
  libXpm,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfiles";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "phillbush";
    repo = "xfiles";
    rev = "master";
    hash = "sha256-Qf/C4OkhvyGDzvmA/07rZAnK9PIsjBSqXIdJaX2AJFg=";
  };

  naviteBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    imlib2Full
    libX11
    libXft
    libXinerama
    fontconfig
    freetype
    libXext
    libXcursor
    libXrender
    libXpm
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 xfiles $out/bin/xfiles

    runHook postInstall
  '';

  meta = {
    description = "File Manager for X";
    homepage = "https://github.com/phillbush/xfiles";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "xfiles";
  };
})
