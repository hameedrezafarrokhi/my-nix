{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs-slim,
  udiskie,
  dmenu,
  libnotify,
  bash,
}:

stdenv.mkDerivation rec {
  pname = "udiskie-dmenu";
  version = "2023-01-30";

  src = fetchFromGitHub {
    owner = "fogine";
    repo = "udiskie-dmenu";
    rev = "61d7642542c5def6129c660d080c13822d76ed8e";
    sha256 = "18x9kwr5fil3ifp8fdiprvw39a1c52cp3g7wfdiy990z578fp1qq";
  };

  buildInputs = [ nodejs-slim udiskie dmenu libnotify ];

  installPhase = ''
    mkdir -p $out/bin
    cp udiskie-dmenu $out/bin/rofi-udiskie
    chmod +x $out/bin/rofi-udiskie
    substituteInPlace $out/bin/rofi-udiskie \
      --replace 'node' '${nodejs-slim}/bin/node'
    substituteInPlace $out/bin/rofi-udiskie \
      --replace '/bin/sh' '${bash}/bin/sh'
  '';

  meta = with lib; {
    homepage = "https://github.com/fogine/udiskie-dmenu";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "udiskie-dmenu";
  };
}
