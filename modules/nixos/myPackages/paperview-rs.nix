{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  stdenv,
  xorg,
  imlib2,
}:

rustPlatform.buildRustPackage rec {
  pname = "paperview-rs";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "eatmynerds";
    repo = "paperview-rs";
    rev = "master";
    hash = "sha256-grb574cXrlCNR5luKMqbkkceww4Pot+r0f8uzWMFhRY=";
  };

  cargoLock = {
    lockFile = ./Paperviewrs-Cargo.lock;
    outputHashes = {
      "imlib-rs-0.1.4" = "sha256-7PUKFELELYU2xhWTmbh6ywrWyP39IoJfNFJVGlTZVFg=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    xorg.libX11
    imlib2
  ];

  meta = {
    description = "Paperview rewrite in rust w/ compositor support";
    homepage = "https://github.com/eatmynerds/paperview-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "paperview-rs";
  };
}
