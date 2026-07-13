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
  openssl,
  mpv,
}:

rustPlatform.buildRustPackage rec {
  pname = "feather-player";
  version = "2026-04-24";

  src = fetchFromGitHub {
    owner = "13unk0wn";
    repo = "Feather";
    rev = "1f1d7be2b146d8de1cbec95851569fa28ea54f1a";
    sha256 = "1pn0him928zpql325ds0vway282nar5pfkfil5faj5k1zkrv6f8r";
  };

  sourceRoot = "source/feather_frontend";

  cargoHash = "sha256-uSroC6GOMjMTMYhARpYGmRyNDszq5lI4KADnpZqF/Tk=";

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
    openssl
    mpv
  ];

  doCheck = false;

  meta = {
    description = " ";
    homepage = "https://github.com/13unk0wn/Feather";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "feather";
  };
}
