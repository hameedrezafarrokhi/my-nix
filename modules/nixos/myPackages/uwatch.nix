{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "uwatch";
  version = "2024-09-25";

  src = fetchFromGitHub {
    owner = "e-tho";
    repo = "uwatch";
    rev = "279e646cc0d411e9de6bf97716d05da5dc39a733";
    sha256 = "1nh3g75019nqrskywkf24r1jv9zwy5fzbjwsbd7x60rp709b3g8v";
  };

  cargoHash = "sha256-rdRDyAPTQMqZ9l0O2VFK8On/Qj42dJ9vBSq6Bv/iI40=";
  release = true;

  meta = with lib; {
    homepage = "https://github.com/e-tho/uwatch";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "uwatch";
  };
}
