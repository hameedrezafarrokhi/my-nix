{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  rustPlatform,
  gtk4-layer-shell,
  gtk4,
  librsvg,
}:

rustPlatform.buildRustPackage rec {
  pname = "ewwii";
  version = "2026-07-13";

  src = fetchFromGitHub {
    owner = "Ewwii-sh";
    repo = "ewwii";
    rev = "1b790d737389362d8e55e75d6d4de1e301a2485c";
    sha256 = "0j24hwxprrjnkbprcyaf09rkqa0xmhci4y44n6n8j75i5nwfmlm9";
  };

  cargoHash = "sha256-sX7QMkRLH1yQr4GlxKBtOF+7qRTxJO6GsDupwQxf3ms=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    freetype
    gtk4
    gtk4-layer-shell
    librsvg
  ];

  cargoBuildInputs = [
    "--bin"
    "ewwii"
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/Ewwii-sh/ewwii";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "ewwii";
  };
}
