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

  cmake,

  wayland,

  libGL,
  libGLX,
  egl-x11,
  egl-wayland,
  glew,
  wlroots_0_19,
  wlr-protocols,
  pixman,
  xdg-desktop-portal-wlr,
  ...

}:

stdenv.mkDerivation rec {
  pname = "customwm";
  version = "2023-12-10";

  src = fetchFromGitHub {
    owner = "andrenho";
    repo = "customwm";
   #rev = "master";
    rev = "ce9ac3a6b92e1c2de5a7a9ec537c2b5d57938fcf";
    sha256 = "0xvn5bg8f3xm0cgd91hrjpp43ain1q0iarasbs2cigi3pn34dbmw";
  };

  nativeBuildInputs = [
    pkg-config
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

    wayland

    libGL
    libGLX
    egl-x11
    egl-wayland
    glew
    wlroots_0_19
    pixman
    wlr-protocols
    xdg-desktop-portal-wlr
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    mkdir build
    cd build

    #To build for X11 only (no OpenGL):
    #cmake -DWITH_OPENGL=OFF -DWITH_WAYLAND=OFF ..

    #To build for X11 only (with OpenGL):
    #cmake -DWITH_WAYLAND=OFF ..

    #To build for Wayland only:
    #cmake -DWITH_X11=OFF ..

    #To build all
    cmake ..

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make install

    #mkdir -p $out/bin
    #cp customwm $out/bin/customwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/andrenho/customwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "customwm";
  };
}
