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
  pname = "tsoomin";
  version = "2023-09-07";

  src = fetchFromGitHub {
    owner = "sqaxomonophonen";
    repo = "tsoomin";
    rev = "4132432b87256afd6defb724d10eecfd18a0074d";
    sha256 = "1pjgrl5glalz78sypcb6aizdrndbnh5hwj33b03v0rfva6ila3dg";
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
    cp tsoomin $out/bin/tsoomin

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/sqaxomonophonen/tsoomin";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "tsoomin";
  };
}
