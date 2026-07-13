{
  lib,
  fetchFromGitHub,
  alsa-lib,
  libpulseaudio,
  pulseaudio,
  pipewire,
  alsa-tools,
  fontconfig,
  freetype,
  dbus,
  pkg-config,
  go,
  buildGoModule,
  playerctl,
}:

buildGoModule rec {
  pname = "podden";
  version = "2025-10-30";

  src = fetchFromGitHub {
    owner = "leanghok120";
    repo = "podden";
    rev = "9643f102c339a97c9e49d991fefa45bda4008b51";
    sha256 = "1h1x9qhq0wa1hhynwp02x6dblif65kj3x19j3g78kxzzrl0v5qjm";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    libpulseaudio
    pulseaudio
    pipewire
    alsa-tools
    fontconfig
    freetype
    dbus
    playerctl
  ];

  vendorHash = "sha256-3JXwHeodgtAGNtVOgrId5PJ6JZ0Up5mWzSBWeR2GFMo=";

  meta = with lib; {
    homepage = "https://github.com/leanghok120/podden";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "podden";
  };
}
