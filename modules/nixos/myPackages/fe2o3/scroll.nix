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

in

rustPlatform.buildRustPackage rec {
  pname = "scroll";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "scroll";
   #rev = "master";
    rev = "b608204546aaeaf72300cf5792a081037c306898";
    sha256 = "1g6di28dl29zlla8i4irwb87k1z8qi210cd8amsd4bdsmkalzqr6";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
  '';

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

 #cargoHash = "sha256-xEpcXkijy1QF4XvG3EIumajIvJhDBCKPxes4m29OkoA=";
 #doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/scroll";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "scroll";
  };
}
