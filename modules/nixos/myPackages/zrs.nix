{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libGL,
  pkg-config,
  libxkbcommon,
  wayland,
  rustPlatform,

  libGLX,
  libGLU,
  glfw,
  glew,
  egl-x11,
  glm,
}:

rustPlatform.buildRustPackage rec {
  pname = "zrs";
  version = "2024-12-03";

  src = fetchFromGitHub {
    owner = "KPMGE";
    repo = "zrs";
    rev = "a6843a088f8144785a8373ea94a61242d6cd826c";
    sha256 = "13782hf89l4d5jphdfizwq45hc23dbbf7vjw5frfvzhy6j07pbgn";
  };

  cargoHash = "sha256-y7+U+R9c2+6vfYTaDAXrnCMM22Fp2FxNmWE2rn6oIYI=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libGL
    wayland
    libxkbcommon

    libGLX
    libGLU
    glfw
    glew
    egl-x11
    glm
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/KPMGE/zrs";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "zrs";
  };
}
