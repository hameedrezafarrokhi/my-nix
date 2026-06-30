{
  lib,
  stdenv,
  fetchFromGitHub,

  fontconfig,
  freetype,

  pkg-config,

  nasm,
  libxcrypt,
}:

stdenv.mkDerivation rec {
  pname = "bolt";
  version = "2026-05-05";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "bolt";
   #rev = "main";
    rev = "652bc4cf9e9bb3a77d778668c670bcb48de5bddd";
    sha256 = "0dbffcvbrx863qp3a5dvydac3kr724xnnn03mcv18zqr8kap5x80";
  };

  nativeBuildInputs = [
    pkg-config
    nasm
  ];

  buildInputs = [
    fontconfig
    freetype
    libxcrypt
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    install -d $out/bin
    install -m 0755 bolt $out/bin/bolt
    install -m 0755 bolt-auth $out/bin/bolt-auth
  '';

  meta = with lib; {
    homepage = "https://github.com/isene/bolt";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bolt";
  };
}
