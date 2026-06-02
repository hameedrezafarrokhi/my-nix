{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  stdenv,
  libX11,
  imlib2,
  glib,
  gtk3,
  xob,
}:

rustPlatform.buildRustPackage rec {
  pname = "barrette";
  version = "2026.02.01";

  src = fetchFromGitHub {
    owner = "lukapeschke";
    repo = "barrette";
    rev = "main";
    hash = "sha256-grnpvf+XyUQYH/ngYI/Z2Q1p2pnyxN99QcGEqsmXGb0=";
  };

  cargoLock = {
    lockFile = ./Barrette-Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    glib
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    imlib2
    gtk3
    xob
  ];

  meta = {
    description = "xob wrapper";
    homepage = "https://github.com/lukapeschke/barrette";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "barrette";
  };
}
