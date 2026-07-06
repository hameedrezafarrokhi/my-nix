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
  pkg-config,
  rustPlatform,

}:

rustPlatform.buildRustPackage rec {
  pname = "hcorner";
  version = "2025-11-29";

  src = fetchFromGitHub {
    owner = "ice2642";
    repo = "hcorner";
    rev = "05a6115a7affc96b5f89c7be138a81cda64e8b1c";
    sha256 = "1r9x1r0gl0sws224dx8ksgxzxv8g4hq9f17yd7p1wl876wfd5zkb";
  };

  cargoLock = {
    lockFile = ./Hcorner-Cargo.lock;
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
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/ice2642/hcorner";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "hcorner";
  };
}
