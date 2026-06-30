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

  highlight = fetchFromGitHub {
    owner = "isene";
    repo = "highlight";
   #rev = "master";
    rev = "17efdab513523f9cab40329b76782936697a4472";
    sha256 = "0607ajcw5cw2bfk3lssynsacqz11n9jp6ib4p8xfdzd7ibknw2vs";
  };

in

rustPlatform.buildRustPackage rec {
  pname = "kastrup";
  version = "2026-06-30";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "kastrup";
   #rev = "master";
    rev = "f2695a3edc070b842fbc3c4ea8fa53f3d78cb899";
    sha256 = "15bmr78jablgld187md8ficz5bn7zln1427was0mqgx1za5xydql";
  };

  buildInputs = [ ];

  prePatch = ''
    mkdir -p highlight
    cp -r ${highlight}/* highlight/

    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
    substituteInPlace Cargo.toml \
      --replace '../highlight' './highlight'
    substituteInPlace highlight/Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-y4jeGyJxOGMelcmQL7lc9dNncxxxzBa2zCb92jYCIfM=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/kastrup";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "kastrup";
  };
}
