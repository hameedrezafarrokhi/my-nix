{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  libX11,
  libxkbcommon,
}:

rustPlatform.buildRustPackage rec {
  pname = "goto-tab";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "diegostafa";
    repo = "goto";
    rev = "master";
    hash = "sha256-4CYZad7xNxz0CjVYzui7x0WmzzBkBFfn6xNphSC7V3E=";
  };

  cargoLock = {
    lockFile = ./Goto-Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    libxkbcommon
  ];

  meta = {
    homepage = "https://github.com/diegostafa/goto";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
