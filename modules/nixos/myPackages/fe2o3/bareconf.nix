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
  pname = "bareconf";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "bareconf";
   #rev = "master";
    rev = "348cd7c152ebdd35e166fd6d32fb4638342abfd7";
    sha256 = "sha256-06ENElMyy9js6TUD4Vlrcwb0HwIYY0wq3hcoKfYBdL4=";
  };

  buildInputs = [ ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
  '';

  cargoHash = "sha256-JS4NDwq7ITRQpVdDLyFF3B0ZKuN0E6N9o7znPpSXBzQ=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/bareconf";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bareconf";
  };
}
