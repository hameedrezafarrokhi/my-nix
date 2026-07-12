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
  cmake,
}:

rustPlatform.buildRustPackage rec {
  pname = "NoctaVox";
  version = "2026-07-11";

  src = fetchFromGitHub {
    owner = "Jaxx497";
    repo = "NoctaVox";
    rev = "32877b2b8a20b3a4a6769a57db60664dfd7d53f0";
    sha256 = "0dqkhh1px6znh3phxx9s9c4mywazgmz4l9xgl6rcrihvf4bfqckk";
  };

  cargoHash = "sha256-p2dEDy3Jaf8MgAcdLPl7AKoNOlLLwdp+rLD5CsyOD8Y=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    cmake
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
    cmake
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/Jaxx497/NoctaVox";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "NoctaVox";
  };
}
