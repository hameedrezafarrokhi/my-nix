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

  glew,
  libGL,
  libGLU,
  libGLX,
  glfw,
  egl-x11,
  egl-wayland,

  makeWrapper,
  autoPatchelfHook,
  zlib,

}:

stdenv.mkDerivation rec {
  pname = "sowon";
  version = "2025-12-03";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "sowon";
    rev = "79b0f4fa3a3f3a6a702e9d25e69d9d7b1f011a06";
    sha256 = "0nsknsnpx274cly584kl3wbbkq3mlqwflwa2a1wy6q3ihw49v9vf";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
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

    glew
    libGL
    libGLU
    libGLX
    glfw
    egl-x11
    egl-wayland
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp sowon $out/bin/sowon

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/sowon \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/sowon || true
  '';

  meta = with lib; {
    homepage = "https://github.com/tsoding/sowon";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sowon";
  };
}
