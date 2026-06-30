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
  pname = "glyph";
  version = "2026-06-19";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "glyph";
   #rev = "main";
    rev = "866e41e884278a61aad5e745ba6dbe53fb410f25";
    sha256 = "06454hsmj5qll9hm987nzff73bhlxwf12l63lrba3qxd3hwhab3v";
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

  installPhase = ''
    mkdir -p $out/bin $out/include $out/lib
    cp glyph $out/bin/glyph
    cp glyph.o $out/lib/glyph.o
    cp glyph.o $out/include/glyph.o
  '';

  meta = with lib; {
    homepage = "https://github.com/isene/glyph";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "glyph";
  };
}
