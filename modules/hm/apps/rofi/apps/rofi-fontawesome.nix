{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "rofi-fontawesome";
  version = "2023-02-21";

  src = fetchFromGitHub {
    owner = "wstam88";
    repo = "rofi-fontawesome";
    rev = "d8e69f8c9e81861e23fbd40ff19691eceedbdc6c";
    sha256 = "0wjznnnf144kpn8nrzsphjszghkv1js8j6ryq1gn5i8wy4f7k7jz";
  };

  installPhase = ''
    mkdir -p $out/bin $out/share/rofi-fontawesome $out/share/man/man1
    cp fontawesome-menu/fontawesome-menu $out/bin/rofi-fontawesome
    chmod +x $out/bin/rofi-fontawesome
    cp fontawesome-menu/fa5-icon-list.txt $out/bin/fa5-icon-list.txt
    cp fontawesome-menu/fontawesome-menu.1 $out/share/man/man1/rofi-fontawesome.1
    cp *.txt $out/share/rofi-fontawesome/
  '';

  meta = with lib; {
    homepage = "https://github.com/wstam88/rofi-fontawesome";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-fontawesome";
  };
}
