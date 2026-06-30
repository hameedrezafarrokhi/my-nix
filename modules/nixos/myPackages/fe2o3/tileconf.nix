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
  pname = "tileconf";
  version = "2026-05-14";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "tileconf";
   #rev = "master";
    rev = "d6ec3dfe650ebe481270e3c79e532b17e537b201";
    sha256 = "03l8nk6kjvcwxfakwgmdr4xc1ahqhpb9gsmkwqlixxfbaa2asb96";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-7f73a+mtN7MW6BIDV7SAGzOikG9oSPC/eOTHnwm2hdA=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/tileconf";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "tileconf";
  };
}
