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

  gtk4,
  libepoxy,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "gtk4_shadertoy";
  version = "2024-12-12";

  src = fetchFromGitHub {
    owner = "gromnitsky";
    repo = "gtk4_shadertoy";
   #rev = "master";
    rev = "c6ee1259c7327f8e7b436f413c4bbdc6867d35ee";
    sha256 = "0ddyg88dqs69jy6l0glhymhmxyvlgpwscp0f37apfyzd1750wicd";
  };

  nativeBuildInputs = [
    pkg-config
    stb
    glew
    libGL
    libGLX
    egl-x11
    glfw
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
    gtk4

  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp _out/gtk4_shadertoy $out/bin/gtk4_shadertoy

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/gromnitsky/gtk4_shadertoy";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gtk4_shadertoy";
  };
}
