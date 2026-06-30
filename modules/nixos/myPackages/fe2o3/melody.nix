{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pulseaudio,
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
  pname = "melody";
  version = "2026-06-29";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "melody";
   #rev = "master";
    rev = "4ed48dbfaee2153bb3e211e15ebb91613544efae";
    sha256 = "1n7mdn61la9dlk22wxw61znd1vn3fzbib1ml95bmw7ncz69akly3";
  };

  buildInputs = [ pulseaudio ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-zL/DVlkoMhYtwZ1MMZMRjXtBJezfpeOmdcpj1y6EIEg=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/melody";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "melody";
  };
}
