{ lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  flex,
  bison,
  imake,
  libX11,
  libXext,
  libXpm,
  xorgproto,
  gcc,
  which,
  imlib2Full,
}:

stdenv.mkDerivation rec {
  pname = "qvwm";
  version = "2019-12-29";

  src = fetchFromGitHub {
    owner = "alivardar";
    repo = "qvwm";
    rev = "master";
    hash = "sha256-gqJIk7KjQvCcArQnE6rOmCxe5+RlyRY1IDaJeUGpIi4=";
  };

  nativeBuildInputs = [ autoconf automake flex bison imake which ];

  buildInputs = [ libX11 libXext libXpm xorgproto imlib2Full ];

  preConfigure = ''
    # Regenerate configure files since they're from automake 1.4
    aclocal
    autoconf
    automake --foreign --add-missing

    # Fix missing includes
    for file in src/*.c src/*.h; do
      substituteInPlace $file --replace '<X11/xpm.h>' '<X11/xpm.h>'
    done
  '';

  configureFlags = [
    "--with-imagedir=${placeholder "out"}/share/qvwm/images"
    "--with-sounddir=${placeholder "out"}/share/qvwm/sounds"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/qvwm/{images,sounds,rc}

    # Install binary
    cp src/qvwm $out/bin/

    # Install data files
    cp -r images/* $out/share/qvwm/images/ 2>/dev/null || true
    cp -r sounds/* $out/share/qvwm/sounds/ 2>/dev/null || true
    cp -r rc/* $out/share/qvwm/rc/ 2>/dev/null || true

    # Install documentation
    mkdir -p $out/share/man/man1
    cp man/qvwm.1 $out/share/man/man1/ 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "A window manager that provides a look and feel similar to OS/2 Warp 4";
    homepage = "https://sourceforge.net/projects/qvwm/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ meee ];
    mainProgram = "qvwm";
  };
}
