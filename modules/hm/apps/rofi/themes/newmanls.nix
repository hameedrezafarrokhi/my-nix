{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "rofi-themes-collection";
  version = "2026-03-03";

  src = fetchFromGitHub {
    owner = "newmanls";
    repo = "rofi-themes-collection";
    rev = "43ec2f5000eb77509b21a46fee07af2c30d815ce";
    sha256 = "1l5qgh8b3chd0fsd96xlxdmvzp6dwzvdgm7w1jd46d1xfrnnzjd4";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/rofi/themes
    cp -r themes/* $out/share/rofi/themes/
  '';

  meta = with lib; {
    homepage = "https://github.com/newmanls/rofi-themes-collection";
    description = " ";
    longDescription = '' '';
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-themes-collection";
  };
}
