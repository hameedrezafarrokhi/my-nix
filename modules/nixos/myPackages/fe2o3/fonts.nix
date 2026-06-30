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
  pname = "fonts";
  version = "2026-06-19";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "fonts";
   #rev = "master";
    rev = "91ccae135c855e3ce6b0a986fdda7ed6423f7b21";
    sha256 = "06cxyc7r8wn9g73g8xsmfz33924bir2scmngaz5j4i21qi64ddgz";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
  '';

  cargoHash = "sha256-EAwdlMNnxdlHnFsDzSvIHa4RmpoWLqnChXx71iu42OI=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/fonts";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fonts";
  };
}
