{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "led";
  version = "2026-05-01";

  src = fetchFromGitHub {
    owner = "miublue";
    repo = "led";
    rev = "main";
    hash = "sha256-8pcimCtZHxzmJcU8MzLaS0omGC+x9Mz0HspqTfIiRyk=";
  };

 #nativeBuildInputs = [ gcc ];

  buildInputs = [ ncurses ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  env.CFLAGS = "-Wall "; # -Werror

  buildPhase = ''
    $CC -O2 -o led led.c -I. -lncurses $CFLAGS
  '';

  installPhase = ''
    install -Dm755 led $out/bin/led
  '';

  meta = {
    homepage = "https://github.com/miublue/led";
    description = "Led Text Editor in Veins of Vim and Nano";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
