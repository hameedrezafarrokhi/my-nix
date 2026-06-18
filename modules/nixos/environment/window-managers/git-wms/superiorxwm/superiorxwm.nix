{
  stdenv,
  lib,
  libX11,
  libXext,
  libXinerama,
  libXft,
  libXrandr,
  xorgproto,
  fetchFromGitHub,
  pkg-config,
  libsxwm,
}:

stdenv.mkDerivation rec {
  pname = "superiorxwm";
  version = "2020-01-01";

  src = fetchFromGitHub {
    owner = "jasonmxyz";
    repo = "sxwm";
    rev = "master";
    hash = "sha256-BMh6WC8e1NdCFMrkV+B23RqrOo3Eea4HkyKYjN8I1RI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libX11
    libXrandr
    xorgproto
    libXext
    libXinerama
    libXft
    libsxwm
  ];

 #postPatch = ''
 #  substituteInPlace Makefile \
 #    --replace '-Llibsxwm -lX11 -lXrandr -lsxwm' 'libsxwm/libsxwm.so -lX11 -lXrandr'
 #'';

  buildPhase = ''
    runHook preBuild

    #make libsxwm/libsxwm.so
    make sxwm
    make sxwmbar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    #mkdir -p $out/lib

    #install -Dm755 libsxwm/libsxwm.so $out/lib/libsxwm.so
    install -Dm755 sxwm $out/bin/sxwm
    install -Dm755 sxwmbar $out/bin/sxwmbar

    runHook postInstall
  '';


 #preBuild = ''
 #  mkdir -p libsxwm
 #'';
 #
 #buildPhase = ''
 #  runHook preBuild
 #
 #  #if [ -f libsxwm/Makefile ]; then
 #  #  cd libsxwm
 #  #  make
 #  #  cd ..
 #  #fi
 #  #make sxwm LDFLAGS="-static"
 #  #make sxwmbar LDFLAGS="-static"
 #
 # #mkdir -p obj dep
 # #find src libsxwm -name "*.c" | while read file; do
 # #  obj=obj/$(basename $file .c).o
 # #  gcc -c -o $obj $file -Iinclude -Ilibsxwm -std=gnu11 -g
 # #done
 # #gcc -o sxwm obj/*.o -lX11 -lXrandr
 # #gcc -o sxwmbar obj/bar.o obj/shared.o -lX11 -lXrandr
 #
 #
 # #cd libsxwm
 # #make
 # #cd ..
 #
 # #gcc -o sxwm \
 # #  src/main.c \
 # #  src/clients.c \
 # #  src/handlers.c \
 # #  src/input.c \
 # #  src/settings.c \
 # #  src/control.c \
 # #  src/util.c \
 # #  src/monitors.c \
 # #  src/ipc.c \
 # #  src/workspaces/workspaces.c \
 # #  src/workspaces/tiling/tiling.c \
 # #  src/workspaces/tiling/clients.c \
 # #  src/frames/frames.c \
 # #  src/frames/basic/basic.c \
 # #  libsxwm/*.o \
 # #  -Iinclude \
 # #  -Ilibsxwm \
 # #  -std=gnu11 \
 # #  -g \
 # #  -lX11 \
 # #  -lXrandr
 # #
 # #gcc -o sxwmbar \
 # #  src/bar.c \
 # #  src/shared.c \
 # #  -Iinclude \
 # #  -std=gnu11 \
 # #  -g \
 # #  -lXrandr
 #
 # #make sxwm LIBS="-lX11 -lXrandr libsxwm/*.o"
 # #make sxwmbar LIBS="-lX11 -lXrandr libsxwm/*.o"
 #
 # #make CC=gcc CFLAGS="-Iinclude -std=gnu11 -g" LIBS="-lX11 -lXrandr -Llibsxwm -lsxwm"
 #
 #  cd libsxwm
 #  make CFLAGS="-I../include -std=gnu11 -g"
 #  cd ..
 #  make sxwm sxwmbar CFLAGS="-Iinclude -std=gnu11 -g"
 #
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #  mkdir -p $out/bin $out/lib
 #  cp sxwm sxwmbar $out/bin/
 #  #cp sxwm $out/bin/superiorxwm-unwrapped
 #  #cp sxwmbar $out/bin/sxwmbar-unwrapped
 #  cp libsxwm/libsxwm.so $out/lib/
 #  #patchelf --set-rpath ${lib.makeLibraryPath buildInputs} $out/bin/superiorxwm-unwrapped
 #  #patchelf --set-rpath ${lib.makeLibraryPath buildInputs} $out/bin/sxwmbar-unwrapped
 #  runHook postInstall
 #'';
 #
 #postFixup = ''
 # #mkdir -p $out/bin $out/lib
 # #cp libsxwm/libsxwm.so $out/lib/
 # #ls -s $out/lib/libsxwm.so /lib/libsxwm.so 2>/dev/null || true
 # #makeWrapper $out/bin/superiorxwm-unwrapped $out/bin/superiorxwm --set LD_LIBRARY_PATH $out/lib
 # #makeWrapper $out/bin/sxwmbar-unwrapped $out/bin/sxwmbar --set LD_LIBRARY_PATH $out/lib
 #  patchelf --set-rpath $out/lib:${lib.makeLibraryPath buildInputs} $out/bin/sxwm
 #  patchelf --set-rpath $out/lib:${lib.makeLibraryPath buildInputs} $out/bin/sxwmbar
 #'';

  meta = with lib; {
    homepage = "https://github.com/jasonmxyz/sxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "superiorxwm";
  };
}
