{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gcc,
  leif,
  libxcb,
  harfbuzz,
  fontconfig,
  freetype,
  libGL,
  glfw,
  cglm,
  libX11,
  libXinerama,
  libXrandr,
  libXrender,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "boron-bar";
  version = "2025-01-01";

  src = fetchFromGitHub {
    owner = "cococry";
    repo = "boron";
    rev = "main";
    hash = "sha256-xaZVcBsOLmZbc93x0dV0tP8s3jGj7sV1DC9V4hUbZC8=";
  };

  nativeBuildInputs = [
    pkg-config
    gcc
    makeWrapper
  ];

  buildInputs = [
    leif
    libxcb
    harfbuzz
    fontconfig
    libGL
    glfw
    cglm
    libX11
    libXinerama
    libXrandr
    libXrender
    freetype
  ];

  buildPhase = ''

  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/boron $out/bin/boron-bar
    cp scripts/* $out/bin/
  '';

  postInstall = ''
    wrapProgram $out/bin/boron-bar \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = {
    homepage = "https://github.com/cococry/boron";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
