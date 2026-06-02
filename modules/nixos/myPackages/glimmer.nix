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
}:

rustPlatform.buildRustPackage rec {
  pname = "glimmer";
  version = "2022.01.01";

  src = fetchFromGitHub {
    owner = "moustacheful";
    repo = "glimmer";
    rev = "master";
    hash = "sha256-y8Lgrqbs0qCFvfqrECFr/JdRGu5QxPlPdCGv0Y8Twww=";
  };

  cargoLock = {
    lockFile = ./Glimmer-Cargo.lock;
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
  ];

  meta = {
    description = "Flash Focus and Bordes";
    homepage = "https://github.com/moustacheful/glimmer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "paperview-rs";
  };
}
