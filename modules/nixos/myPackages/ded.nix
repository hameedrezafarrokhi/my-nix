{
  lib,
  gcc15Stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  SDL2,
  glew,
  libGL,
  libGLU,
  libGLX,
  glfw,
  egl-x11,
  egl-wayland,
}:

gcc15Stdenv.mkDerivation rec {
  pname = "ded";
  version = "2023-07-18";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "ded";
    rev = "ea30e9d6ee1c0d52aa11f9386920b884987a6b55";
    sha256 = "0r9wbln7ma24jw4rzsnxqkcfg7d6k28cpiq3rxckbrij40sfz6lz";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    SDL2
    glew
    libGL
    libGLU
    libGLX
    glfw
    egl-x11
    egl-wayland
  ];

  buildPhase = ''
    runHook preBuild

    ./build.sh
    ./ded src/main.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ded $out/bin/ded

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tsoding/ded";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ded";
  };
}
