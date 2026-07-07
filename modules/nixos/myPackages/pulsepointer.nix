{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,

  rustPlatform,
  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  makeWrapper,
  autoPatchelfHook,
  zlib,

  glew,
  libGL,
  libGLU,
  libGLX,
  glfw,
  egl-x11,
  egl-wayland,
  freeglut,

  pulseaudio,
  libpulseaudio,
  dbus,
  alsa-tools,
  alsa-lib,
  ffmpeg,
  pango,
  cairo,
  libxfixes,
  pipewire,
  portaudio,
  ncurses,
  fftw,
  SDL2,
}:

rustPlatform.buildRustPackage rec {
  pname = "pulsepointer";
  version = "2025-12-14";

  src = fetchFromGitHub {
    owner = "simonskrede";
    repo = "pulsepointer";
    rev = "a8de57ba6ede06f7e6f54931764b4dcb51f0630f";
    sha256 = "0l49dwcc9lj0l75dgv1c2p6nmarbn2ivh98hi3g55njgprha94y5";
  };

  cargoHash = "sha256-hDOLy7wMGIUXlGCHIVGVgy/RrMAlDCBdCZ/cnYQWhT0=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    ffmpeg
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    freeglut
    glew
    libGL
    libGLU
    libGLX
    glfw
    egl-x11
    egl-wayland
    pulseaudio
    libpulseaudio
    dbus
    alsa-tools
    alsa-lib
    pango
    cairo
    libxfixes
    pipewire
    portaudio
    ncurses
    fftw
    SDL2
  ];

  postFixup = ''
    wrapProgram $out/bin/pulsepointer \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/pulsepointer || true
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/simonskrede/pulsepointer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "pulsepointer";
  };
}
