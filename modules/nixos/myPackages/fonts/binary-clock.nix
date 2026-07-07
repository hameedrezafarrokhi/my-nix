{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installFonts,
  fontconfig,
  freetype,
}:

stdenvNoCC.mkDerivation rec {
  pname = "polybar-binary-clock-fonts";
  version = "2024-04-06";

  src = fetchFromGitHub {
    owner = "jamessouth";
    repo = "polybar-binary-clock-fonts";
    rev = "c52c1b9658b38c142bc4c2e9899b78ed515b726c";
    sha256 = "176xjh6b3am7ky449yhjbd946ps6c0i11ijqbx6ycf0r9mavz1vy";
  };

  nativeBuildInputs = [ installFonts ];

  dontBuild = true;

  meta = with lib; {
    homepage = "https://github.com/jamessouth/polybar-binary-clock-fonts";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "polybar-binary-clock-fonts";
  };
}
