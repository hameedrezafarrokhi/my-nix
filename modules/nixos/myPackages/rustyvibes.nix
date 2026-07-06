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
  libpulseaudio,
  pulseaudio,
  pipewire,
  alsa-tools,

}:

rustPlatform.buildRustPackage rec {
  pname = "rustyvibes";
  version = "2024-07-07";

  src = fetchFromGitHub {
    owner = "KunalBagaria";
    repo = "rustyvibes";
    rev = "b3f48dcf309b70f09eaf68d6fdf6a477eceab23b";
    sha256 = "1bydqw65r8ql66dhz4pim7zfzl0k4kxp6yk24k610n2y0awcb0wh";
  };

  cargoLock = {
    lockFile = ./Rustyvibes-Cargo.lock;
  };

 #cargoHash = lib.fakeHash;

  prePatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
  '';

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
    libpulseaudio
    pulseaudio
    pipewire
    alsa-tools
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/KunalBagaria/rustyvibes";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "rustyvibes";
  };
}
