{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeText,
  conf ? ''
    @import "murzchnvok/config/general"
    @import "murzchnvok/config/disable-prompt"
    @import "murzchnvok/colorscheme/rosepine"
    @import "murzchnvok/themes/murz"
  '',
}:

stdenvNoCC.mkDerivation rec {
  pname = "rofi-collection";
  version = "2026-01-11";

  src = fetchFromGitHub {
    owner = "Murzchnvok";
    repo = "rofi-collection";
    rev = "d3a0874fcf905fa0d702d8edbaee0af9cc9be8e3";
    sha256 = "11mg3j7yy33fs1vdapvciz5vr3aqg9jmiqr2pc3r03naqp33csr8";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "murzchnvok.rasi" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} murzchnvok.rasi";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/rofi/themes/murzchnvok
    cp -r ./* $out/share/rofi/themes/murzchnvok/
    cp murzchnvok.rasi  $out/share/rofi/themes/murzchnvok.rasi
  '';

  meta = with lib; {
    homepage = "https://github.com/Murzchnvok/rofi-collection";
    description = " ";
    longDescription = '' '';
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-themes-collection";
  };
}
