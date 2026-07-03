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

  libGL
, libGLU
, freeglut
, glib
, egl-x11
, libGLX
, glfw
, soil
, imgui
, lua
, glm
, glew
, gtk3
, makeWrapper
, wayland
, libxfixes
, libxxf86vm

, cmake

}:

stdenv.mkDerivation rec {
  pname = "glsl-editor";
  version = "2026-01-12";

  src = fetchFromGitHub {
    owner = "Catraq";
    repo = "glsl-editor";
    rev = "25e79aea80dd9bd4c1fc19233629130c10dadb4d";
    sha256 = "1jbj2a6s0rqcryhcq491dn5s9jxl0klapkzdk891wc2b87rlgsiy";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
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

    libGL
    libGLU
    freeglut
    glib
    egl-x11
    libGLX
    glfw
    soil
    imgui
    lua
    glm
    glew
    gtk3
    makeWrapper
    wayland
    libxfixes
    libxxf86vm
  ];

  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp glsl-editor $out/bin/glsl-editor

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Catraq/glsl-editor";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "glsl-editor";
  };
}
