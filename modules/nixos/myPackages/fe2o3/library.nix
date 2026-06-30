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
  pname = "library";
  version = "2026-06-30";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "library";
   #rev = "master";
    rev = "d997de38aa1ba75a15649b16b748e51475831f2a";
    sha256 = "1vfjzpgdw6ri1pypkhvdl5sbzx7s4snakdd46dbq927934haik7c";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
  '';

  cargoHash = "sha256-vVpSb7lARmRsFimOwQHBc4P9mc8Gc/ZgeLr3ucxqlbs=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/library";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "library";
  };
}
