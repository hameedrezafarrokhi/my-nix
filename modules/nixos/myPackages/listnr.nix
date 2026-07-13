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
  pname = "listnr";
  version = "2025-09-04";

  src = fetchFromGitHub {
    owner = "sammwyy";
    repo = "listnr";
    rev = "920ba2fbd8ca22892ae1ccd842387a8df3f8f7b7";
    sha256 = "18qma1jd1w6z1fhl0jpc141wq0x97blamblqd2295lbmz8w8f1hm";
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

  vendorHash = "sha256-osbL4S3FX1yZMfrfcRnsTXY39+5UBf/J8PadWdS260E=";

  meta = with lib; {
    homepage = "https://github.com/sammwyy/listnr";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "listnr";
  };
}
