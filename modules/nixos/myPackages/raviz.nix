{
  lib,
  stdenv,
  fetchFromGitHub,

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

  fontconfig,
  freetype,

  pkg-config,

  cmake,
  libpulseaudio,
  pulseaudio,

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

  git,
}:

stdenv.mkDerivation rec {
  pname = "raviz";
  version = "2026-02-22";

  src = fetchFromGitHub {
    owner = "maskedsyntax";
    repo = "raviz";
    rev = "bf6399a0c393e1525239e82faca204521a778fa0";
    sha256 = "00vlrfycdj92whiis097xs0gcp523k6kyilk6jsnldy3ixx01wjd";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
    autoPatchelfHook

  ];

  buildInputs = [
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

    fontconfig
    freetype

    libpulseaudio
    pulseaudio

    zlib

    glew
    libGL
    libGLU
    libGLX
    glfw
    egl-x11
    egl-wayland
    freeglut

    git
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    mkdir build && cd build
    cmake ..
    make
    make install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    wrapProgram $out/bin/raviz \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/raviz || true

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/maskedsyntax/raviz";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "raviz";
  };
}
