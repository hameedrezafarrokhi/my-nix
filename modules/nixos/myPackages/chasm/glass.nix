{
  lib,
  stdenv,
  fetchFromGitHub,

  fontconfig,
  freetype,

  pkg-config,

  nasm,
}:

let

  glyph = fetchFromGitHub {
    owner = "isene";
    repo = "glyph";
   #rev = "main";
    rev = "866e41e884278a61aad5e745ba6dbe53fb410f25";
    sha256 = "06454hsmj5qll9hm987nzff73bhlxwf12l63lrba3qxd3hwhab3v";
  };

in

stdenv.mkDerivation rec {
  pname = "glass";
  version = "2026-06-11";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "glass";
   #rev = "main";
    rev = "340f95a9c3a7b923e064fbed0b2680a75ba8aa38";
    sha256 = "1b7k0kdzilhs8x345m26hqiaqsmqa5gzcaa8xqljj2wpgk10pd47";
  };

  nativeBuildInputs = [
    pkg-config
    nasm
  ];

  buildInputs = [
    fontconfig
    freetype
  ];

  postPatch = ''
    substituteInPlace glass.asm \
      --replace '../glyph/glyph.asm' '${glyph}/glyph.asm'
  '';

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    homepage = "https://github.com/isene/glass";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "glass";
  };
}
