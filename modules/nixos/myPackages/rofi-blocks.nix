{
  lib,
 #stdenv,
  gcc13Stdenv,
  fetchFromGitHub,
 #meson,
 #ninja,
  autoreconfHook,
  cairo,
  pkg-config,
  json-glib,
  rofi-unwrapped,
}:

#stdenv.mkDerivation rec {
gcc13Stdenv.mkDerivation rec {
  pname = "rofi-blocks";
  version = "2024-08-07";

  src = fetchFromGitHub {
    owner = "OmarCastro";
    repo = "rofi-blocks";

   #rev = "d75a9da1516daeef33a13714dfe19d2da9d6c819";
   #sha256 = "1rp6cjjlpiv6jcpw0rad3c6sg0ca4ysp4nfpna00dryb5q2rin9y";

    rev = "0a2ba561aa9a31586c0bc8203f8836a18a1f664e";
    hash = "sha256-U955hzd55xiV5XdQ18iUIwNLn2JrvuHsItgUSf6ww58=";
  };

  nativeBuildInputs = [
    pkg-config
   #meson
   #ninja
    autoreconfHook
    json-glib
  ];

  buildInputs = [ cairo rofi-unwrapped ];

  patches = [ ./rofi-blocks-patch ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  pwd
 #  ls
 #  bababooi
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/OmarCastro/rofi-blocks";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-blocks";
  };
}
