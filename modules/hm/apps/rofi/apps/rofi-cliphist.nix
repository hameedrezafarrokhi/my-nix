{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cliphist,
  rofi,
}:

rustPlatform.buildRustPackage rec {
  pname = "rofi-cliphist";
  version = "2026-05-29";

  src = fetchFromGitHub {
    owner = "szaffarano";
    repo = "rofi-tools";
    rev = "8320d27877480d3556399c7e6a37df307175f93b";
    sha256 = "0x812akqv44bzx6ny17y6rxfmkbia7lmpxg9sakcix7rpjph9bc6";
  };

  buildInputs = [ cliphist rofi ];

  cargoHash = "sha256-AULLQYIfuP2lK4a6AHF8qpNwgc7DJDL1OiKpw75QJoQ=";

  meta = with lib; {
    description = "Rofi extensions";
    homepage = "https://github.com/szaffarano/rofi-tools";
    license = licenses.mit;
    mainProgram = "rofi-cliphist";
    maintainers = [];
  };
}
