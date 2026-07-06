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

  openal-soft,
  libsndfile,
  openal,
  libpulseaudio,
  pulseaudio,
  alsa-tools,
  alsa-utils,


}:

rustPlatform.buildRustPackage rec {
  pname = "modelm";
  version = "2018-08-09";

  src = fetchFromGitHub {
    owner = "millerjs";
    repo = "modelm";
    rev = "a80b69ccb7b0d65ccb8d0b865d3b8519cf733120";
    sha256 = "0v48ysa5ka4a7z1kyns3gfh9yx7gj1f28xfwqrc7y8nz9lhchg1q";
  };

  cargoHash = lib.fakeHash;

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
    openal-soft
    openal
    libpulseaudio
    pulseaudio
    libsndfile
    alsa-tools
    alsa-utils
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/millerjs/modelm";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "modelm";
  };
}
