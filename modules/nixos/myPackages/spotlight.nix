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

  libGL,
  libGLX,
  libGLU,
  glfw,
  glew,
  egl-x11,
  glm,

}:

stdenv.mkDerivation rec {
  pname = "spotlight";
  version = "2026-05-24";

  src = fetchFromGitHub {
    owner = "al1maher";
    repo = "spotlight";
    rev = "bcd8953d67716c878026ff9f44d8001e6695a8e9";
    sha256 = "1vhsdrzd4ihh35xfhnancb03s391ckz59919gyk4p7adq3niwwik";
  };


  nativeBuildInputs = [
    pkg-config
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

    libGL
    libGLX
    libGLU
    glfw
    glew
    egl-x11
    glm
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp spotlight $out/bin/spotlight

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/al1maher/spotlight";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "spotlight";
  };
}
