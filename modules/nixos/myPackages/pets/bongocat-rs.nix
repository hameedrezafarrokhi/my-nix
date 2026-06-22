{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libXcursor,
  libXi,
  libGL,
  pkg-config,
  libxkbcommon,
  wayland,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bongocat-rs";
  version = "2025-06-05";

  src = fetchFromGitHub {
    owner = "CanadianBaconBoi";
    repo = "bongocat-rs";
    rev = "fec264efa5d8397a2151645e327dcdd9a56bd2ed";
    sha256 = "0wxq8y5rkkxrwix3jbgdlkw1xgv91qpay7hrqlzra4fkg87y67qn";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "enum-map-2.6.2" = lib.fakeHash;
      "ecolor-0.31.1" = "sha256-lTKx64ksxFH/6Q4TotZLbrRlpwBCqP3xEvla8LkApvM=";
    };
  };

 #cargoHash = "sha256-nXF2Yj1ilMUpHtUAdSp7r0tkuWizITTAuoByxp5omE0=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libX11
    libXi
    libXext
    libXrandr
    libGL
    wayland
    libxkbcommon
    libXcursor
  ];

  meta = {
    description = "bongocat x zoomer rust";
    homepage = "https://github.com/CanadianBaconBoi/bongocat-rs";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "bongocat-rs";
  };
}
