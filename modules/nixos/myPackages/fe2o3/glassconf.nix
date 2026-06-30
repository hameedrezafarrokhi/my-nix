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
  pname = "glassconf";
  version = "2026-05-14";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "glassconf";
   #rev = "master";
    rev = "f687a9ccedce84024665fff23a3e46192e327751";
    sha256 = "0mgl1fpkmxzbxar6vp9bqh308m87yv8cl0ykvsgi00xcjdfc2jjn";
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
    lockFile = ./Glassconf-Cargo.lock;
  };

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/glassconf";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "glassconf";
  };
}
