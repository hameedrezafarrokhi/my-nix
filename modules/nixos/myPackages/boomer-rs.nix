{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libGL,
  pkg-config,
  libxkbcommon,
  wayland,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "boomer-rs";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "AlphaLawless";
    repo = "boomer-rs";
    rev = "main";
    hash = "sha256-J4/eIrOt0+j8xMUOwSiAM9jjoT2DCgd3Kx1LCeoS7JQ=";
  };

  cargoLock = {
    lockFile = ./Boomer-rs-Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libGL
    wayland
    libxkbcommon
  ];

  meta = {
    description = "boomer x zoomer rust";
    homepage = "https://github.com/AlphaLawless/boomer-rs";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "boomer-rs";
  };
}
