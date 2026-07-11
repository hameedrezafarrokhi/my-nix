{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "rofi-mixer";
  version = "2025-08-20";

  src = fetchFromGitHub {
    owner = "joshpetit";
    repo = "rofi-mixer";
    rev = "981207a13d9b1d9334f40e8c2c68ba6c2d774200";
    sha256 = "14sfp58fn21xgnj2vd5a90jw6cp18jxxpri7nxs7sxssr0gq6fi4";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp src/rofi-mixer $out/bin/rofi-mixer
    cp src/rofi-mixer.py $out/bin/rofi-mixer.py
    chmod +x $out/bin/rofi-mixer.py
    chmod +x $out/bin/rofi-mixer
  '';

  meta = with lib; {
    homepage = "https://github.com/joshpetit/rofi-mixer";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-powerblur";
  };
}
