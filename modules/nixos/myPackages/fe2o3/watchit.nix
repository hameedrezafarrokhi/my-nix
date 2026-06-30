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
  pname = "watchit";
  version = "2026-06-17";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "watchit";
   #rev = "master";
    rev = "445655ebf52e710d81dda1d8d61e4841cb912f71";
    sha256 = "1m0vi0qi0la72b37pbzrwgls78f5fiqjajmpyhmwxw7cxzs1gyfl";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
  '';

  cargoHash = "sha256-xKSXQ4bEQAql2SMTsTN8rWPhueNxaySg8kPwsTpZ7No=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/watchit";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "watchit";
  };
}
