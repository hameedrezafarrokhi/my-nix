{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  alsa-lib,
  libpulseaudio,
  pulseaudio,
  pipewire,
  alsa-tools,
  fontconfig,
  freetype,
  dbus,
  chromaprint,
}:

rustPlatform.buildRustPackage rec {
  pname = "TMPlayer";
  version = "2026-04-09";

  src = fetchFromGitHub {
    owner = "professor-lee";
    repo = "TMPlayer";
    rev = "9753f205a941677a7e0d09e00508e5eaba507204";
    sha256 = "0wn35ihvbbxlbsvqcwr11ix0ldqxi725sz4y4z9s6vkkdyvag38b";
  };

  cargoHash = "sha256-Fi2sGxHl13R8NQyyUuk5bgFBoQMm4FDEnn+T1jJ7CK4=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    freetype
    alsa-lib
    libpulseaudio
    pulseaudio
    pipewire
    alsa-tools
    dbus
    chromaprint
  ];

  doCheck = false;

  meta = {
    description = " ";
    homepage = "https://github.com/professor-lee/TMPlayer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "TMPlayer";
  };
}
