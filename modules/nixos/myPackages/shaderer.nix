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

  premake5,
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
}:

stdenv.mkDerivation rec {
  pname = "Shaderer";
  version = "2020-09-17";

  src = fetchFromGitHub {
    owner = "Anex007";
    repo = "Shaderer";
    rev = "172f1de6576f3a0f29117c120f88f0b49400bb49";
    sha256 = "09sh34sydy7dqagq8l00p6dd654q2rwbcgzvlzjr834sr5v042d8";
  };

  nativeBuildInputs = [
    pkg-config
    premake5
    lua
    makeWrapper
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
    libxfixes
    libxxf86vm

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
    wayland
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  preConfigure = ''
    premake5 gmake2
  '';

  buildPhase = ''
    runHook preBuild

    make -C Shaderer config="release_linux_x86_64"

    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp Shaderer $out/bin/Shaderer
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/Anex007/Shaderer";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "Shaderer";
  };
}
