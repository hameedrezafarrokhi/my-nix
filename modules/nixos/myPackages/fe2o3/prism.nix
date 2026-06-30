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
  pname = "prism";
  version = "2026-06-17";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "prism";
   #rev = "master";
    rev = "8b7582663688c2b3ef61c0cac978b5266d6b9738";
    sha256 = "0zkkgrmgay3yl8mg82z9n5wxjzc7g79j93hmmn0fkxshwp960m9k";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-hcN5/nKuJ0J0lPSPzbUhpEiALxxhQ3Xej1T1BOpU/+0=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/prism";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "prism";
  };
}
