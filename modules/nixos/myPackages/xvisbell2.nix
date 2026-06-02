{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "xvisbell2";
  version = "2020-01-01";

  src = fetchFromGitHub {
    owner = "a8f";
    repo = "xvisbell2";
    rev = "master";
    hash = "sha256-Hf2HQ43F0QDdMt/NoGbQrQcuhWf5hfowUOKbWVtWna8=";
  };

  nuildInputs = [ gcc ];

  buildInputs = [ libx11 ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  env.CFLAGS = "-Wall -Wextra -Werror -std=gnu99";

  buildPhase = ''
    $CC $CFLAGS -c xvisbell.c -o xvisbell.o
    $CC $CFLAGS -o xvisbell xvisbell.o $LDFLAGS -lX11
  '';

  installPhase = ''
    install -Dm755 xvisbell $out/bin/xvisbell2
  '';

  meta = {
    homepage = "https://github.com/a8f/xvisbell2";
    description = "Flash Focus For X";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
