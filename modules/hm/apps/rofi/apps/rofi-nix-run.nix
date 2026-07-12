{
  lib,
  stdenv,
  fetchFromGitHub,
  rofi-unwrapped,
  glib,
  cairo,
  yyjson,
  zenity,
  nix,
  cmake,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "rofi-nix-run";
  version = "2026-04-16";

  src = fetchFromGitHub {
    owner = "ITHackerstein";
    repo = "rofi-nix-run";
    rev = "76d6e3c9a1d57837b69783e0a834114f8026bd36";
    sha256 = "15zgcn8s976k6w94xqpxcm4f7870538k6sh3h2sw0hmkicfacsim";
  };

  buildInputs = [
    rofi-unwrapped
    glib
    cairo
    yyjson
    zenity
    nix
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  postPatch = ''
      substituteInPlace src/constants.h \
          --replace-warn '#define NIX_BINARY "nix"' '#define NIX_BINARY "${lib.getExe nix}"' \
          --replace-warn '#define ZENITY_BINARY "zenity"' '#define ZENITY_BINARY "${lib.getExe zenity}"'
  '';

  meta = {
      description = "Simple Rofi plugin to launch Nix packages (especially GUI programs).";
      homepage = "https://github.com/ITHackerstein/rofi-nix-run";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
  };
}
