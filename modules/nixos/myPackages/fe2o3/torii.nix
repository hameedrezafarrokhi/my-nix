{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "torii";
  version = "2026-05-05";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "torii";
   #rev = "master";
    rev = "5b2b25c57cefdfb529207ea904da8367c9750ed2";
    sha256 = "0w5zdvrd08wp9q27mlglfrn2mvqr1kx2zpsa3y9gdqmxzpvfjqys";
  };

  buildInputs = [ ];

  cargoHash = "sha256-8/KDldfdfD/ANyb8tGJJf3NOK2zUJbCS6g5XKLy5fwg=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/torii";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "torii";
  };
}
