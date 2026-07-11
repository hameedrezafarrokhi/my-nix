{
  lib,
  rustPlatform,
  fetchFromGitHub,
  rofi,
}:

rustPlatform.buildRustPackage rec {
  pname = "marcador";
  version = "2024-01-07";

  src = fetchFromGitHub {
    owner = "joajfreitas";
    repo = "marcador";
    rev = "036ee335306a9aec19e2336f8a57f1ef73604429";
    sha256 = "1y6kq5v29nm6qkdq5pxmmiqxmlj72si2qwkafwdwc2hm7zb6677b";
  };

  buildInputs = [ rofi ];

  cargoHash = lib.fakeHash;

  meta = with lib; {
    description = "Rofi Bookmark Manager";
    homepage = "https://github.com/joajfreitas/marcador";
    mainProgram = "marcador";
    maintainers = [];
  };
}
