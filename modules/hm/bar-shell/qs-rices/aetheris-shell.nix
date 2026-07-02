{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "aetheris-shell";
  version = "2026-05-29";

  src = fetchFromGitHub {
    owner = "MarioRRom";
    repo = "aetheris-shell";
   #rev = "main";
    rev = "e40a7566d313276de49abbe72fbd2d9b888ec8b9";
    sha256 = "1l9d1iidbpp4cyypp1jd986a3lyf8s27is5n2y4wbc11zfwh0v9m";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/${pname}
    cp -r ${src}/* $out/share/${pname}/
  '';

  meta = with lib; {
    homepage = "https://github.com/MarioRRom/aetheris-shell";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "aetheris-shell";
  };
}
