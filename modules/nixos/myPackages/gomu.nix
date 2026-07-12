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
}:

buildGoModule rec {
  pname = "gomu";
  version = "2026-06-05";

  src = fetchFromGitHub {
    owner = "raziman18";
    repo = "gomu";
    rev = "469e935c45469a475bd454cac4be725ba1a2aeb4";
    sha256 = "1hfa6qdajxga1z9gvxsslq8ag6zqgjmrds7nk56s6084cdpj8lkz";
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
  ];

  vendorHash = "sha256-KvZ1OHg8br3e1aW/gjdBio02ypYNvpWyEtW9C7WjTAg=";

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  meta = with lib; {
    homepage = "https://github.com/raziman18/gomu";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gomu";
  };
}
