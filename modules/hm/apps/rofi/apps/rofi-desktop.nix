{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "rofi-desktop";
  version = "2026-06-04";

  src = fetchFromGitHub {
    owner = "giomatfois62";
    repo = "rofi-desktop";
    rev = "0b89a6aca109cb077ec06345e6de917d8c5bc382";
    sha256 = "0i9zjgg3m0y8r6pch07l28khiggyn7clwr0kj6g6s89hmrrjswhi";
  };

  installPhase = ''
    mkdir -p $out/share/rofi-desktop
    cp -r ./* $out/share/rofi-desktop/
  '';

  meta = with lib; {
    homepage = "https://github.com/giomatfois62/rofi-desktop";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-desktop";
  };
}
