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

  glow = fetchFromGitHub {
    owner = "isene";
    repo = "glow";
   #rev = "master";
    rev = "9af8ac03e37f79d87ef8fe81a1ce14e4d729efec";
    sha256 = "1ms56p58dsvx2yfsj7iqjgk550q4mp4xgx8nvpswsi235ir24606";
  };

  orbit = fetchFromGitHub {
    owner = "isene";
    repo = "orbit";
   #rev = "master";
    rev = "d5f53f82d6017995cb2df4ec34e28285ca01b434";
    sha256 = "110gc3b2rykvhwgqqw3d116gq0a87d9akwccdzyy4ad16wxy1hyz";
  };
  orbit-lock = ./Orbit-Cargo.lock;

in

rustPlatform.buildRustPackage rec {
  pname = "astro";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "astro";
   #rev = "master";
    rev = "d5bf0b4060daff279f4f1072a02dfe202b3d3e63";
    sha256 = "0784561vn7g31mjn35qh9najnh2n623fw234rdswfn684gq02xfq";
  };

  buildInputs = [ ];

  prePatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
    mkdir -p orbit
    cp -r ${orbit}/* orbit/
    cp ${orbit-lock} orbit/Cargo.lock

    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
    substituteInPlace Cargo.toml \
      --replace 'orbit = { git = "https://github.com/isene/orbit", tag = "v0.1.3", package = "fe2o3-orbit" }' \
                 'orbit = { version = "0.1.3", path = "./orbit", package = "fe2o3-orbit" }'
  '';

  cargoLock = {
    lockFile = ./Astro-Cargo.lock;
  };

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/astro";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "astro";
  };
}
