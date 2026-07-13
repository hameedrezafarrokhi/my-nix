{
  lib,
  stdenv,
  fetchzip,
  pkg-config,
  glib,
  makeWrapper,
  autoPatchelfHook,
  zlib,
  alsa-lib,
  libpulseaudio,
  pulseaudio,
  pipewire,
  alsa-tools,
  fontconfig,
  freetype,
  dbus,
  playerctl,
  icu,
}:

stdenv.mkDerivation rec {

  pname = "MusicSharp-bin";
  version = "2026-06-18";

  src = fetchzip {
    url = "https://github.com/markjamesm/MusicSharp/releases/download/v2.0.0/MusicSharp-v2.0-linux-x64.tar.gz";
    sha256 = "1wj9frdkwczwl78kq0fd6j3mp1s9jj159r02aljcrnjfvxl6538i";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

  buildInputs = [
    zlib
    alsa-lib
    libpulseaudio
    pulseaudio
    pipewire
    alsa-tools
    fontconfig
    freetype
    dbus
    playerctl
    icu
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/MusicSharp $out/bin/MusicSharp
    chmod +x $out/bin/MusicSharp
  '';

  postFixup = ''
    wrapProgram $out/bin/MusicSharp \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/MusicSharp || true
  '';

  meta = {
    description = "MusicSharp";
    homepage = "https://github.com/markjamesm/MusicSharp";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "MusicSharp";
  };
}
