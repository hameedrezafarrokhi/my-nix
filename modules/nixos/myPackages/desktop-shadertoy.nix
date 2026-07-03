{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  fontconfig,
 #freetype,
  pkg-config,
  cmake,
  openssl,
  glfw,

}:

stdenv.mkDerivation rec {
  pname = "desktop-shadertoy";
  version = "2025-06-08";

  src = fetchFromGitHub {
    owner = "GabeRundlett";
    repo = "desktop-shadertoy";
    rev = "07cf6f244857b6282e500101bd992926be98eb51";
    sha256 = "0z8aiy2wfdjnw7s66qp6fjrqly36skqr1r5n10hh2d3d42wwrp42";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    libx11
    fontconfig
   #freetype
    openssl
    glfw
  ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp desktop-shadertoy $out/bin/desktop-shadertoy
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/GabeRundlett/desktop-shadertoy";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "desktop-shadertoy";
  };
}
