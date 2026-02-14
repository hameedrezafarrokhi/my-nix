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
  pname = "xfiles-root";
  version = "1.0.0";

  src = "${inputs.xfiles}/xfiles-papirus-macchiato-sapphire/root";

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

    install -Dm755 xfiles $out/bin/xfiles-root

    runHook postInstall
  '';

  meta = {
    description = "File Manager for X (Root)";
    homepage = "https://github.com/phillbush/xfiles";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "xfiles-root";
  };
})
