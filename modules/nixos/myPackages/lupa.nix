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

  glfw,
  libGL,
  libGLX,
  egl-x11,
  glew,
  stb,

  libepoxy,
 #busybox,

  open-fonts,

}:

stdenv.mkDerivation rec {
  pname = "lupa";
  version = "2025-10-21";

  src = fetchFromGitHub {
    owner = "flebedev77";
    repo = "lupa";
   #rev = "master";
    rev = "a63fab9ed462029575f5b9dfa51542ed059cfb72";
    sha256 = "1iz9q9bvaazjj0pa4nz5426zaxyx4ya9yyll3x0s8qgxdpgcvr0v";
  };

  nativeBuildInputs = [
    pkg-config
    stb
    glew
    libGL
    libGLX
    egl-x11
    glfw
   #busybox
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

    glfw
    libGL
    libGLX
    egl-x11
    glew
    stb
    libepoxy

    open-fonts
  ];

  buildPhase = ''
    runHook preBuild

    make -B

    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp lupa $out/bin/lupa
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/flebedev77/lupa";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "lupa";
  };
}
