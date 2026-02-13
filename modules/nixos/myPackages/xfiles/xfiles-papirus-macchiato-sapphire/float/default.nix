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
  inputs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfiles-float";
  version = "1.0.0";

  src = "${inputs.xfiles}/xfiles-papirus-macchiato-sapphire/float";

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

    install -Dm755 xfiles $out/bin/xfiles-float

    runHook postInstall
  '';

  meta = {
    description = "File Manager for X (Floating)";
    homepage = "https://github.com/phillbush/xfiles";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "xfiles-float";
  };
})
