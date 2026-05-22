{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXinerama,
  libXft,
  xorgproto,
  pkg-config,
  writeText,
  patches ? [ ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "monsterwm";
  version = "2012-01-01-${src.rev}";

  src = fetchFromGitHub {
    owner = "c00kiemon5ter";
    repo = "monsterwm";
    rev = "master"; # master / core / xinerama-master / xinerama-core / xinerama-init

    hash = "sha256-JSIcNxiWi1we9x6tyW6nJRDwlgvlWSDtdGHFDgyNXlc=";   # Master
   #hash = "sha256-336H+8un5UDo87aljU1VCfNrnRvQJYLhoJQPKibTwkA=";   # Xinerama Master
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXext
    libXinerama
    libXft
    xorgproto
  ];

  inherit patches;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";


 #preBuild = ''
 #  cp config.def.h config.h
 #
 #  substituteInPlace Makefile \
 #    --replace "-L/usr/lib" "" \
 #    --replace "-I/usr/include" "" \
 #    --replace "/usr/X11R6" "libX11.dev"
 #'';
 #
 #makeFlags = [
 #  "PREFIX=${placeholder "out"}"
 #  "MANPREFIX=${placeholder "out"}/share/man"
 #  "X11INC=-I${libX11.dev}/include"
 #  "X11LIB=-L${libX11.out}/lib -lX11"
 #  "LIBS=-L${libX11.out}/lib -lc -lX11"
 #];
 #
 #installTargets = [ "install" ];

  preBuild = ''
    cp config.def.h config.h
  '';

  buildPhase = ''
    runHook preBuild
    ${stdenv.cc.targetPrefix}cc -std=c99 -pedantic -Wall -Wextra \
      -I. -I${libX11.dev}/include \
      -DVERSION=\"${version}\" \
      -c monsterwm.c -o monsterwm.o
    ${stdenv.cc.targetPrefix}cc \
      -o monsterwm \
      monsterwm.o \
      -L${libX11.out}/lib \
      -lX11 \
      -lc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    cp monsterwm $out/bin/
    cp monsterwm.1 $out/share/man/man1/
    cp config.h $out/config-default.h
    cp monsterwm.c $out/monsterwm-patched.c
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/c00kiemon5ter/monsterwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "monsterwm";
  };
}
