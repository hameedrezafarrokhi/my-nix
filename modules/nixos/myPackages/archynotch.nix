{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  libX11,
  libxkbcommon,
  alsa-lib-with-plugins,
  openssl,
  freetype,
  expat,
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
  ];

  buildInputs = [
    libX11
    libxkbcommon
    expat
    freetype
    openssl
    alsa-lib-with-plugins
  ];

  meta = {
    homepage = "https://github.com/ind4skylivey/archynotch";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
