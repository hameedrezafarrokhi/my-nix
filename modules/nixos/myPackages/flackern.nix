{
  lib,
  stdenv,
  fetchFromGitea,

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

  ffmpeg,
  nlohmann_json,
  spdlog,
  SDL2,
  SDL2_image,
  wayland,
  wayland-protocols,
  wayland-scanner,
  kdePackages,
  ecm,
  libGL,
  libGLX,
  libGLU,
  glew,
  glm,
  egl-x11,
  egl-wayland,

  libwebp,
  webp-pixbuf-loader,
  libtiff,
  imagemagick,

}:

stdenv.mkDerivation rec {
  pname = "flackern";
  version = "2026-01-01";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "KTuff";
    repo = "flackern";
    rev = "bc07f8816fcd810a6ee6a629ba11d209cb761a04";
    sha256 = "1ph73gjzy9z3imwcz63fb74mf64nghr7za6g3s3aqg5swqdjk0bq";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    kdePackages.extra-cmake-modules
    ecm
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

    ffmpeg
    nlohmann_json
    spdlog
    SDL2
    SDL2_image
    wayland
    wayland-protocols
    wayland-scanner
    ecm

    libGL
    libGLX
    libGLU
    glew
    glm
    egl-x11
    egl-wayland

    libwebp
    webp-pixbuf-loader

    libtiff
    imagemagick

  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p build
    cmake -B ./build -DCMAKE_BUILD_TYPE=Release

    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp flackern $out/bin/flackern
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/KTuff/flackern";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "flackern";
  };
}
