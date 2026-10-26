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

  raylib,
  glfw,
  libGL,
  libGLX,
  libGLU,
  glew,
  egl-x11,

  clang,
}:

stdenv.mkDerivation rec {
  pname = "ssuika";
  version = "2020-10-21";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "nzuum";
    repo = "ssuika";
    rev = "8c942c0e9ced3ae6a912e8805e909fdc3a5c2670";
    sha256 = "0i36lx2npkph8gwm4cdd5qrqm05s19rk7x01k0hk0jl80yh34xgj";
  };

  nativeBuildInputs = [
    pkg-config
    clang
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

    raylib
    glfw
    libGL
    libGLX
    libGLU
    glew
    egl-x11
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/ssuika $out/bin/ssuika

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/nzuum/ssuika";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ssuika";
  };
}
