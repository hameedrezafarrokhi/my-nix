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
  cmake,
  playerctl,
  SDL2,
  SDL2_Pango,
  SDL2_image,
  SDL2_mixer,
  SDL2_sound,
  SDL2_ttf,
}:

stdenv.mkDerivation rec {
  pname = "MinimalistMP3Player";
  version = "2026-06-19";

  src = fetchFromGitHub {
    owner = "Ardet696";
    repo = "MinimalistMP3Player";
    rev = "85d0375d58061190186c9131e0aeeafacbdfdcc8";
    sha256 = "0g3mbpm2wp7c214jkz358qa57bv26plg0r3jfjyd23r01cs0jc6y";
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
    playerctl
    SDL2
    SDL2_Pango
    SDL2_image
    SDL2_mixer
    SDL2_sound
    SDL2_ttf
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

 #buildPhase = ''
 #  runHook preBuild
 #
 #  cmake ..
 #  make
 #
 #  runHook postBuild
 #'';

 #installPhase = ''
 #  runHook preInstall
 #
 #  make install
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/Ardet696/MinimalistMP3Player";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "MinimalistMP3Player";
  };
}
