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

  libGL,
  pkg-config,
  gcc,
  nim,
  glib,
  libGLU,
  libGLX,
  freeglut,
  egl-x11,
  makeWrapper,
  autoPatchelfHook,
  zlib,
  glfw,
}:

stdenv.mkDerivation rec {

  pname = "shader-playground-bin";
  version = "2026-07-03";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "68808fda32d59c81cf6792efea63ff221e8ef975";
    sha256 = "0kq05shwixpi2nlgcqijlbmvhjkvmlk8f6g1pa14yja2pfspxrzi";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

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

    libGL
    libGLU
    freeglut
    glib
    egl-x11
    libGLX
    glfw
    fontconfig
    freetype
  ];

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/shader_playground/shader_playground $out/bin/shader-playground
  '';

  installPhase = ''
    wrapProgram $out/bin/shader-playground \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/shader-playground || true
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/foltik/shader-playground";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "shader-playground";
  };
}
