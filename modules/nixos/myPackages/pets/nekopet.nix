{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libGL,
  pkg-config,
  libxkbcommon,
  wayland,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "nekopet";
  version = "2026-06-18";

  src = fetchFromGitHub {
    owner = "dhruvkumar1805";
    repo = "nekopet";
   #rev = "main";
    rev = "bc44b92f5fa0bbe1cb496254d0b9b5c1cf961d8c";
    sha256 = "1m2c5wd4hbpf6fgagp2gsy1x3ya4h5n0hykdap93rh26mh76z2b9";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libGL
    wayland
    libxkbcommon
  ];

  postFixup = ''
    mkdir -p $out/share/nekopet-src
    cp -r ${src}/* $out/share/nekopet-src

    # Create Launcher
    cat > $out/bin/nekopet-launch << 'EOF'
    #!/usr/bin/env bash

    cd /run/current-system/sw/share/nekopet-src
    /run/current-system/sw/bin/nekopet

    EOF

    chmod +x $out/bin/nekopet-launch

  '';

  meta = {
    description = "desktop anime";
    homepage = "https://github.com/dhruvkumar1805/nekopet";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "nekopet";
  };
}
