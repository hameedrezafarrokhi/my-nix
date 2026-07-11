{
  lib,
  stdenv,
  fetchFromGitHub,
  installFonts,
}:

stdenv.mkDerivation rec {
  pname = "rofi-powerblur";
  version = "2019-10-15";

  src = fetchFromGitHub {
    owner = "lu0";
    repo = "rofi-blurry-powermenu";
    rev = "43403ef28a96368928d6be7fb3d33a0fb7179858";
    sha256 = "1pwl7ndkihhqd0bmsbir5b0sflvzx5rwd3b154k7dsyj3rd9gpa4";
  };

  buildInputs = [ installFonts ];

  installPhase = ''
    mkdir -p $out/bin $out/share/rofi-powerblur
    cp ./powermenu_theme.rasi $out/share/rofi-powerblur/
    cp ./powermenu.sh $out/share/rofi-powerblur/rofi-powerblur
    chmod +x $out/share/rofi-powerblur/rofi-powerblur
    ln -sf $out/share/rofi-powerblur/rofi-powerblur $out/bin/rofi-powerblur
  '';

  meta = with lib; {
    homepage = "https://github.com/lu0/rofi-blurry-powermenu";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-powerblur";
  };
}
