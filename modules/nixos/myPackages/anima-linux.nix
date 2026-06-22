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
  libappindicator-gtk3,
  libappindicator,
  libindicator-gtk3,
  libayatana-indicator,
  libayatana-appindicator,
  libayatana-common,
  gtk3,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  pname = "anima-linux";
  version = "2026-04-30";

  src = fetchFromGitHub {
    owner = "Zylquinal";
    repo = "anima-linux";
   #rev = "master";
    rev = "c28c7f158940cb8f5177e3ce74a5782cd5d7a71f";
    sha256 = "1c33bvrlxcmhwz0qwzdcw5cp5yshxdl0rfbm4rsvnqraxfsjg0jj";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
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
    libappindicator-gtk3
    libappindicator
    libindicator-gtk3
    libayatana-indicator
    libayatana-appindicator
    libayatana-common
    gtk3
    sqlite
  ];

  buildPhase = ''
    runHook preBuild
    cargo build --release --no-default-features
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp anima-linux $out/bin/anima-linux
    runHook postInstall
  '';

  meta = {
    description = "desktop anime";
    homepage = "https://github.com/Zylquinal/anima-linux";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "anima-linux";
  };
}
