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

  highlight = fetchFromGitHub {
    owner = "isene";
    repo = "highlight";
   #rev = "master";
    rev = "17efdab513523f9cab40329b76782936697a4472";
    sha256 = "0607ajcw5cw2bfk3lssynsacqz11n9jp6ib4p8xfdzd7ibknw2vs";
  };

in

rustPlatform.buildRustPackage rec {
  pname = "scribe";
  version = "2026-06-26";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "scribe";
   #rev = "master";
    rev = "6a4fee0b28c946377cfca1b7fc8125ea2b209a22";
    sha256 = "1l3p1f8l0887s2k9vmp9qgp24i2nih4isfjkgfcd1bn7lxpfzpk2";
  };

  buildInputs = [ ];

  prePatch = ''
    mkdir -p highlight
    cp -r ${highlight}/* highlight/

    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../highlight' './highlight'
    substituteInPlace highlight/Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-CVaJIustrDQMiIvkesqJM2yKCQsmEXEiZgh7rvmgRBo=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/scribe";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "scribe";
  };
}
