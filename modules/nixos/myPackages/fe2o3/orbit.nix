{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "orbit";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "orbit";
   #rev = "master";
    rev = "d5f53f82d6017995cb2df4ec34e28285ca01b434";
    sha256 = "110gc3b2rykvhwgqqw3d116gq0a87d9akwccdzyy4ad16wxy1hyz";
  };

  buildInputs = [ ];

  postPatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Orbit-Cargo.lock;
  };

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/orbit";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "orbit";
  };
}
