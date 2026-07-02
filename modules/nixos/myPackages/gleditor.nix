{
  lib,
  gcc13Stdenv,
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

  gtk3,
  gtksourceview4,
  libepoxy,

  cmake,

  libportal-gtk3,
  xdg-desktop-portal-gtk,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "gleditor";
  version = "2026-01-11";

  src = fetchFromGitHub {
    owner = "1ay1";
    repo = "gleditor";
   #rev = "master";
    rev = "48c0d67f9a2bb0993b037c546936b8b00a5b58da";
    sha256 = "0yscazkk6wrmf2cm3ly43d1v325w6ckaxdjy3ac4kf7l5qis5acn";
  };

  nativeBuildInputs = [
    pkg-config
    stb
    glew
    libGL
    libGLX
    egl-x11
    glfw
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

    glfw
    libGL
    libGLX
    egl-x11
    glew
    stb
    libepoxy
    gtk3
    gtksourceview4
    libportal-gtk3
    xdg-desktop-portal-gtk

  ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp gleditor $out/bin/gleditor
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/1ay1/gleditor";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gleditor";
  };
}
