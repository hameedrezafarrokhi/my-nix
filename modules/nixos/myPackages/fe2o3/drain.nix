{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

let

  crust = fetchFromGitHub {
    owner = "isene";
    repo = "crust";
   #rev = "master";
    rev = "7d2e5ef009042c299b3c84ebd249df1f0f3e3103";
    sha256 = "0fsxiwp25qf7p8h6674n1bmmfci3kahkjhvvc0n9xz1fy4d2dfl3";
  };

in

rustPlatform.buildRustPackage rec {
  pname = "drain";
  version = "2026-06-30";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "drain";
   #rev = "master";
    rev = "a358111240e9a4802dbbcd9eb3aa1e269793e5b4";
    sha256 = "1n1zx4iji40am3mzp7i3i7klkq1bnc2rgjrb0b93gpflny3wldw4";
  };

  buildInputs = [ ];

  prePatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} ./Cargo.lock
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoLock = {
    lockFile = ./Drain-Cargo.lock;
  };

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/drain";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "drain";
  };
}
