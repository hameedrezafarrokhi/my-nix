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
  pname = "gazette";
  version = "2026-06-30";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "gazette";
   #rev = "master";
    rev = "541d009557324fa1cb3ff34c4d02ec95032ec64e";
    sha256 = "1j56jj1s1xp2jh8l8xrh4sddnzxdxlq24z9nm0qx0r74cd1z7hkr";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-AOCYnDMHC7rd48Wkr8nXjNt7ubZO9Jo23YaUEj0bMXE=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/gazette";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gazette";
  };
}
