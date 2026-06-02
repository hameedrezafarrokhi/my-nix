{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "xvisbell";
  version = "2018-01-01";

  src = fetchFromGitHub {
    owner = "girst";
    repo = "xvisualbell-mirror-of-git.gir.st";
    rev = "master";
    hash = "sha256-0Kw7JSo0LiRqvCHyV0ORdNVnR+LThBQluT3cd10m8Gc=";
  };

 #nativeBuildInputs = [ gcc ];

  buildInputs = [ libx11 ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  env.CFLAGS = "-Wall -Wextra -Werror -std=gnu99";

  buildPhase = ''
    $CC $CFLAGS -c xvisbell.c -o xvisbell.o
    $CC $CFLAGS -o xvisbell xvisbell.o $LDFLAGS -lX11
  '';

  installPhase = ''
    install -Dm755 xvisbell $out/bin/xvisbell
  '';

  meta = {
    homepage = "https://github.com/girst/xvisualbell-mirror-of-git.gir.st";
    description = "Flash Focus For X";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
