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

  rustPlatform,

  cairo,
  dbus,

}:

rustPlatform.buildRustPackage rec {
  pname = "boringwm";
  version = "2026-02-17";

  src = fetchFromGitHub {
    owner = "dennishilk";
    repo = "boringwm";
   #rev = "main";
    rev = "5fbe580abd078fc280c40e70673fdde5b77db22a";
    sha256 = "10v3b7i7p5j57jclwcs9g4qy159c10g1w2y36p9bss97w5sczsss";
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

    cairo
    dbus
  ];

  postPatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

 #cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/dennishilk/boringwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "boringwm";
  };
}
