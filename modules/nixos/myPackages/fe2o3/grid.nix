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
  pname = "grid";
  version = "2026-06-17";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "grid";
   #rev = "master";
    rev = "a91dea69f7456967bc3927c65500529b5f031f63";
    sha256 = "0xbi9j6rginfnkasbj0rb5a5kk1qi0d91lcbih7j10i9y44a82h0";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-D/9bXS+t3bScBMl8dAmurDt3r8W/nDPPVU/fk0k2EW8=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/grid";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "grid";
  };
}
