{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "vswm";
  version = "2022-01-01";

  src = fetchFromGitHub {
    owner = "laskarelias";
    repo = "vswm";
    rev = "master";
    hash = "sha256-tQWaE9WUuPzvHREdve24mHvxWvZEzdNOdJ2rqeZTu0A=";
  };

 #CFLAGS = "-O3 -I${libX11.dev}/include -D_POSIX_C_SOURCE=200809L";

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [
    "PREFIX=${placeholder "out"}"
   #"CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp vswm $out/bin/
  '';

 #installTargets = [];
 #
 #buildPhase = ''
 # #sed -i '1#include <stdlib.h>\n#include <string.h>\n#include <stdio.h>\n#include <time.h>' vswm.c
 # #$CC -pedantic -Wall -O3 -I${libX11.dev}/include vswm.c -L${libX11.out}/lib -lX11 -o vswm || \
 # #$CC -Wall -O3 -I${libX11.dev}/include vswm.c -L${libX11.out}/lib -lX11 -o vswm
 #
 #  $CC -Wall -O3 -Wno-pointer-sign \
 #  -Wno-builtin-declaration-mismatch \
 #  -Wno-incompatible-pointer-types \
 #  -Wno-unused-variable \
 #  -Wno-unused \
 #  -Wno-implicit-function-declaration \
 #  -I${libX11.dev}/include vswm.c -L${libX11.out}/lib -lX11 -o vswm
 #
 #'';

  meta = with lib; {
    homepage = "https://github.com/laskarelias/vswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "vswm";
  };
}
