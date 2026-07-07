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
}:

rustPlatform.buildRustPackage rec {
  pname = "wiremann";
  version = "2026-05-30";

  src = fetchFromGitHub {
    owner = "wiremann";
    repo = "wiremann";
    rev = "270d8e1fda490b2d1badcd6dc480a807f2fed23e";
    sha256 = "1xc4hq6sivsr84873wkv849csf2lqgk1zhpirkcsdyi6h9xdwan1";
  };

  cargoHash = "sha256-SmOm2bT2br+xbkAgl7eNk8NbE+Zzwx1y22ONR+A6iOM=";

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
  ];

  postFixup = ''
    wrapProgram $out/bin/wiremann \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/wiremann || true
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/wiremann/wiremann";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "wiremann";
  };
}
