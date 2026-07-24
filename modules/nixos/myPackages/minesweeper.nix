{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "minesweeper";
  version = "2019-12-10";

  src = fetchFromGitHub {
    owner = "unknownblueguy6";
    repo = "MineSweeper";
    rev = "454957752a47d8dae8b9cf7ded8586acbeade1c0";
    sha256 = "04mlr6lnpla8ax6hj510yiy9jambw2bcjw37pfpwnqjhnp4x06ny";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp mine $out/bin/minesweeper

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/unknownblueguy6/MineSweeper";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "minesweeper";
  };
}
