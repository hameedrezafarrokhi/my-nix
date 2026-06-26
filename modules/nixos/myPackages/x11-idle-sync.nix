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
  libxscrnsaver,

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
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "x11-idle-sync";
  version = "2024-09-08";

  src = fetchFromGitHub {
    owner = "shouya";
    repo = "x11-idle-sync";
   #rev = "master";
    rev = "fb2908ac95bba0d75546af9b78c6dee7d0fdcf7d";
    sha256 = "1phqx0rz2g2x51zfq0qj4jz9wq750dfhbnvma3fsjg7a93agdda3";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

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
    libxscrnsaver

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
  ];

  meta = {
    description = "sync loginconfd with x11 screensaver time (conflicts with xss service)";
    homepage = "https://github.com/shouya/x11-idle-sync";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "x11-idle-sync";
  };
}
