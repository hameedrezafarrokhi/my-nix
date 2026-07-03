{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cmake,
}:

let

  naga = fetchFromGitHub {
    owner = "foltik";
    repo = "naga";
    rev = "652b65cfa9cff89435526ecbb96702f0b3b9b9e1";
    sha256 = "15lr51v4zq49mrrn0lny02n2dxgc2vw2sp1bdaan5si4jc34g6js";
  };
  naga-lock = ./Naga-Cargo.lock;

in

rustPlatform.buildRustPackage rec {
  pname = "Shader-Playground";
  version = "2024-01-21";

  src = fetchFromGitHub {
    owner = "foltik";
    repo = "Shader-Playground";
    rev = "0b67163073d1f5a03e20578419176629071ee3a6";
    sha256 = "16pcr2xrlzk8v31099dcg3nk625x2q4igmn66sn3armwv45rqbby";
  };

  prePatch = ''

    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
    mkdir -p naga
    cp -r ${naga}/* naga/
    cp ${naga-lock} naga/Cargo.lock

    substituteInPlace Cargo.toml \
      --replace '../naga' '${naga}'

  '';

  nativeBuildInputs = [ cmake ];

 #cargoHash = "sha256-vBw7jFqYIbrbcakiGuujf5nU2sTqFQ88UA2F17Rd80Q=";

  cargoLock = {
    lockFile = ./Shader-Playground-Cargo.lock;
    outputHashes = {
      "pp-rs-0.1.0" = "sha256-VSQJbBXmN45tpv2wSfVIWrdaDeVzTrV3d52An3+9c44=";
    };
  };

  meta = {
    description = " ";
    homepage = "https://github.com/foltik/Shader-Playground";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "Shader-Playground";
  };
}
