{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "rofi-copyq";
  version = "2019-10-15";

  src = fetchFromGitHub {
    owner = "cjbassi";
    repo = "rofi-copyq";
    rev = "2ce8628b1e17d91c82d6d40302f1325f3edee207";
    sha256 = "0p07kj9miq9390349x936j51lflb0w530kw3hv6qj3jm5cm5sg64";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/bin
    cp rofi-copyq $out/bin/rofi-copyq
    chmod +x $out/bin/rofi-copyq
  '';

  meta = with lib; {
    homepage = "https://github.com/cjbassi/rofi-copyq";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-copyq";
  };
}
