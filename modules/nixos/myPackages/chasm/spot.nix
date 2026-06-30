{
  lib,
  stdenv,
  fetchFromGitHub,

  fontconfig,
  freetype,

  pkg-config,

  nasm,
}:

stdenv.mkDerivation rec {
  pname = "spot";
  version = "2026-06-18";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "spot";
   #rev = "main";
    rev = "0a59d1d65c949a9290b2322be773376329079e18";
    sha256 = "08l609fksww8mqb76drp8jqfbhydxmbh0vrh24whrrz5kksrc15b";
  };

  nativeBuildInputs = [
    pkg-config
    nasm
  ];

  buildInputs = [
    fontconfig
    freetype
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    homepage = "https://github.com/isene/spot";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "spot";
  };
}
