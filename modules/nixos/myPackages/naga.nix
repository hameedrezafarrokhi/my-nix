{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "naga";
  version = "2021-05-21";

  src = fetchFromGitHub {
    owner = "foltik";
    repo = "naga";
    rev = "652b65cfa9cff89435526ecbb96702f0b3b9b9e1";
    sha256 = "15lr51v4zq49mrrn0lny02n2dxgc2vw2sp1bdaan5si4jc34g6js";
  };

  prePatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Naga-Cargo.lock;
    outputHashes = {
      "pp-rs-0.1.0" = "sha256-VSQJbBXmN45tpv2wSfVIWrdaDeVzTrV3d52An3+9c44=";
    };
  };

  meta = {
    description = " ";
    homepage = "https://github.com/foltik/naga";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "naga";
  };
}
