{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  alsa-lib,
  libpulseaudio,
  pulseaudio,
  pipewire,
  alsa-tools,
  dbus,
  portaudio,
  mpg123,
  love,
  lua,
  cmake,
  playerctl,
  libjack2,
  jack2,
  ncurses,
}:

stdenv.mkDerivation rec {
  pname = "rhythm";
  version = "2025-10-23";

  src = fetchFromGitHub {
    owner = "TrisH0x2A";
    repo = "rhythm";
    rev = "a49cb2bc9f791143eac0019328ebc19648e73559";
    sha256 = "08yaql4l94s4i3sdbip9nln01sc9w5dm275nrvpfph0fgxji7yz7";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    alsa-lib
    libpulseaudio
    pulseaudio
    pipewire
    alsa-tools
    dbus
    fontconfig
    freetype
    portaudio
    mpg123
    love
    lua
    playerctl
    libjack2
    jack2
    ncurses
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  buildPhase = ''
    runHook preBuild

    mkdir build && cd build

    cmake ..
    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make install

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/TrisH0x2A/rhythm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rhythm";
  };
}
