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
  pname = "show";
  version = "2026-05-05";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "show";
   #rev = "main";
    rev = "d39ca5429cdce9e048a4d2f1e492f2e1e7aa9328";
    sha256 = "1lvsgx04w4fjcp6nyvlnz8ai8x6i2rg5ap6cx6vy4g6y3ygkx9ml";
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
    homepage = "https://github.com/isene/show";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "show";
  };
}
