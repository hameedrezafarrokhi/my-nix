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

  libGL,
  pkg-config,

  wayland,
  rustPlatform,

  libGLX,
  libGLU,
  glfw,
  glew,
  egl-x11,
  glm,
  cmake,
}:

rustPlatform.buildRustPackage rec {
  pname = "monocle-zoom";
  version = "2025-01-29";

  src = fetchFromGitHub {
    owner = "thatmagicalcat";
    repo = "monocle";
    rev = "48f662c16a577fd76593f54931a11ce4439258db";
    sha256 = "1ysc19nmc2bci998g2plh3mz20fhqfxi2ld802yjfc56ajrdarjr";
  };

  cargoHash = "sha256-bgkuBm4aL5OYmFyP1kGXTJvt7bILq3XjYD7oJ3cyTAo=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
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

    libGL
    wayland

    libGLX
    libGLU
    glfw
    glew
    egl-x11
    glm
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/thatmagicalcat/monocle";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "monocle";
  };
}
