{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,

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
  gcc,
  glib,
  libGLU,
  libGLX,
  freeglut,
  egl-x11,
  makeWrapper,
  autoPatchelfHook,
  zlib,
  glfw,
  soil,
}:

rustPlatform.buildRustPackage rec {
  pname = "shadertoy-rs";
  version = "2023-11-10";

  nativeBuildInputs = [ pkg-config makeWrapper autoPatchelfHook ];

  buildInputs = [
    openssl

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
    soil
  ];

  src = fetchFromGitHub {
    owner = "fmenozzi";
    repo = "shadertoy-rs";
    rev = "d12337073a3b223fe9bfd382cbad2b6e867ffbe1";
    sha256 = "0alqkjbnrn258wy7i8pbwkzb0wa4kv5qp1zczxybpm6p96rpffnp";
  };

  cargoHash = "sha256-AEhmogawbCdzzyq0XzhXgap7hhao2rUS4WTbQV6udeA=";

  postFixup = ''
    wrapProgram $out/bin/shadertoy \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/shadertoy || true
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/fmenozzi/shadertoy-rs";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "shadertoy-rs";
  };
}
