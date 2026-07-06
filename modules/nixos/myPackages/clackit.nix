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

  libxtst,

  fontconfig,
  freetype,
  pkg-config,

  rustPlatform,
  alsa-lib,


}:

rustPlatform.buildRustPackage rec {
  pname = "clackit";
  version = "2024-07-26";

  src = fetchFromGitHub {
    owner = "benodiwal";
    repo = "clackit";
    rev = "e5ba8d2768a944c30acad6efdc70ac3c23b5c2ae";
    sha256 = "0m21f2y7hb4zq8m12krjvf2m9gd6rmvzrdjw6v5dw5ab1qfx2lz0";
  };

  cargoHash = "sha256-+VyuaIzTwnPeT9rLgFx9WhdeDyNPsNW0VwMLTcEQOAI=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
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
    alsa-lib
    libxtst
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/benodiwal/clackit";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "clackit";
  };
}
