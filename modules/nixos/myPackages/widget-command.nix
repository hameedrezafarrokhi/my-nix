{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  rustPlatform,
  pango,
  cairo,
  gdk-pixbuf-xlib,
  gdk-pixbuf,
  gtk4,
  gtk4-layer-shell,
}:

rustPlatform.buildRustPackage rec {
  pname = "widget-command";
  version = "2026-05-20";

  src = fetchFromGitHub {
    owner = "Loz-tech";
    repo = "widget-command";
    rev = "62749c12b7ff95e8f584fc2a7df5da94978f081d";
    sha256 = "1r308a7bcvbqcbq70gipszk7rqs4jbfm3v5mk6l2njpj2j3mcgbr";
  };

  cargoHash = "sha256-ZSfz3EhirqVAfwXBc4uv5OnmSr9MxqN8De5PLQNy0Jc=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    freetype
    pango
    cairo
    gdk-pixbuf-xlib
    gdk-pixbuf
    gtk4
    gtk4-layer-shell
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/Loz-tech/widget-command";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "widget-command";
  };
}
