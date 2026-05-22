{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  clang-tools,
}:

stdenv.mkDerivation rec {
  pname = "clarawm";
  version = "2022-8-25";

  src = fetchFromGitHub {
    owner = "dacousb";
    repo = "clarawm";
    rev = "master";
    hash = "sha256-8iOcL1SzVrOJcSCseGrfd8nuEnTnAp3nSFBKxKntE3o=";
  };

  nativeBuildInputs = [ clang-tools ];

  buildInputs = [ libX11 libXext ];

  buildPhase = ''
    clang clarawm.c -o clarawm -02 -Wall -Werror -lX11
  '';

  meta = with lib; {
    homepage = "https://github.com/dacousb/clarawm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "clarawm";
  };
}
