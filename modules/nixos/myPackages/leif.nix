{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  glfw,
  cglm,
  libclipboard,
}:

stdenv.mkDerivation rec {
  pname = "leif";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "cococry";
    repo = "leif";
    rev = "main";
    hash = "sha256-EWB3M5kmEGv4va1v/Q1HXK6gYSof4At153zTmqQwIUY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ glfw cglm libclipboard ];

  NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
    "-I${cglm}/include/cglm"
    "-I${src}/vendor/glad/include"
    "-I${src}/vendor/stb_image"
    "-I${src}/vendor/stb_truetype"
    "-I${src}/vendor/stb_image_resize"
    "-DLF_GLFW"
    "-DGLM_FORCE_RADIANS"
    "-DGLM_FORCE_DEPTH_ZERO_TO_ONE"
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p lib
    $CC $NIX_CFLAGS_COMPILE -O3 -ffast-math -c leif.c  -o lib/leif.o \
      -I${cglm}/include
    $CC -c vendor/glad/src/glad.c -o lib/glad.o
    ar cr lib/libleif.a lib/*.o
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/include/leif
    cp lib/libleif.a $out/lib/
    cp -r include/leif/* $out/include/leif/
    mkdir -p $out/share/leif
    cp -r .leif $out/share/leif 2>/dev/null || true
    cp -r ${cglm}/include/cglm $out/include/
    runHook postInstall
  '';

  postPatch = ''
    substituteInPlace Makefile \
      --replace "cp -r .leif ~/" " " \
      --replace "rm -rf ~/.leif/" " " || true
  '';

  meta = {
    homepage = "https://github.com/cococry/leif";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
