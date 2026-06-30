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
  pname = "stripconf";
  version = "2026-05-14";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "stripconf";
   #rev = "master";
    rev = "a92a0ca2d5368344a451386835a0bc6d36befc7e";
    sha256 = "05vmpy7wqr54z88d8pzw8p715ap7h56gkg2wqfh3barbri6vhxwa";
  };

  buildInputs = [ ];

  prePatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoLock = {
    lockFile = ./Stripconf-Cargo.lock;
  };

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/stripconf";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "stripconf";
  };
}
