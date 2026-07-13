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
  playerctl,
}:

rustPlatform.buildRustPackage rec {
  pname = "orbit-player";
  version = "2026-06-10";

  src = fetchFromGitHub {
    owner = "sihooleebd";
    repo = "orbit";
    rev = "5ae07e02fd97ad24fa0033216d4300f12ab7f759";
    sha256 = "0p254yn9avqgjf41xd6s5zkhdp4vl22wigdxh66r48gkhvc7f25a";
  };

  cargoHash = "sha256-lr0fAEYbQH0zt4g+UWPTa5oKxOITK1++N2qpLabbVWA=";

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
    playerctl
  ];

  doCheck = false;

  meta = {
    description = " ";
    homepage = "https://github.com/sihooleebd/orbit";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "orbit";
  };
}
