{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXinerama,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "zwm-c";
  version = "2026-01-04";

  src = fetchFromGitHub {
    owner = "dczheng";
    repo = "zwm";
   #rev = "master";
    rev = "2f9be85431ad2c33a2b3fec567155aaa1cb457b1";
    sha256 = "18yhvsb5xl230ngana9rlmzwhh4lk5d8widfzi18c0l9jnd7gsq4";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 libXinerama ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" ];

  installPhase = ''
    mkdir -p $out/bin
    cp zwm $out/bin/zwm-c
  '';

  meta = with lib; {
    homepage = "https://github.com/dczheng/zwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zwm-c";
  };
}
