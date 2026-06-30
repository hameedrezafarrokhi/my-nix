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
  pname = "bare";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "bare";
   #rev = "main";
    rev = "d0b3525e531574a0f668aa7efb79a4961322f38a";
    sha256 = "043sng42qlhpjql1ns5r2hjziqrbhd4bhr8w81gs26jq7nrskjjk";
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
    homepage = "https://github.com/isene/bare";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bare";
  };
}
