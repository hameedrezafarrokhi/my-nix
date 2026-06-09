{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,

  libX11,
  libxcursor,
  libXext,
  libXrandr,
  libXrender,
  libxcomposite,
  libxcb,
  libxcb-image,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libXinerama,
  libXi,
  libXft,
  libxres,
  libxpm,

  libxkbcommon,
  alsa-lib-with-plugins,
  openssl,
  freetype,
  expat,
  dbus,
}:

rustPlatform.buildRustPackage rec {
  pname = "archynotch";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "ind4skylivey";
    repo = "archynotch";
    rev = "main";
    hash = "sha256-1hGoM5xrWj5abct765BwJt0mwC3JgoNYmY4E9Wc31Uk=";
  };

  cargoLock = {
    lockFile = ./Archynotch-Cargo.lock;
  };

  prePatch = ''
    cp ${cargoLock.lockFile} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    expat
    dbus
  ];

  buildInputs = [

    libX11
    libxcursor
    libXext
    libXrandr
    libXrender
    libxcomposite
    libxcb
    libxcb-image
    libxcb-cursor
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    libXinerama
    libXi
    libXft
    libxres
    libxpm

    libxkbcommon
    expat
    freetype
    openssl
    alsa-lib-with-plugins
    dbus
  ];

  meta = {
    homepage = "https://github.com/ind4skylivey/archynotch";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
