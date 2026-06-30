{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "crust";
  version = "2026-06-17";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "crust";
   #rev = "master";
    rev = "7d2e5ef009042c299b3c84ebd249df1f0f3e3103";
    sha256 = "0fsxiwp25qf7p8h6674n1bmmfci3kahkjhvvc0n9xz1fy4d2dfl3";
  };

  buildInputs = [ ];

  cargoHash = "sha256-7+1HsP9QkS7PQ+I2H9vk69Flo/m0zhzF7z/HPuEV7vY=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/crust";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "crust";
  };
}
