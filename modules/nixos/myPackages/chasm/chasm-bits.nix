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
  pname = "chasm-bits";
  version = "2026-05-31";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "chasm-bits";
   #rev = "main";
    rev = "4392aa2d14b412d6aa5a4214e308db2ae961244c";
    sha256 = "0pb6a2h2mabi1hwl3r3113y4jwnpn30wrk9dzcdg9n7liap38abx";
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
    homepage = "https://github.com/isene/chasm-bits";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "chasm-bits";
  };
}
