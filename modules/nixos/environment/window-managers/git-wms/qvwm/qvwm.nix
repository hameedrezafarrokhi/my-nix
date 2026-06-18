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
  autoreconfHook,
  libtool,
  which,
  gettext,
  imlib2Full,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "qvwm";
  version = "2019-12-29";

  src = fetchFromGitHub {
    owner = "alivardar";
    repo = "qvwm";
   #rev = "master";
    rev = "3312f715504f7094d30ff453b2e4bdf613a7a224";
    sha256 = "0bi2m50pk29n40sidjb5wkkmwb4qrsm169xl0afg0hm3na9li8l2";
  };

  nativeBuildInputs = [
    autoconf
    libtool
    gettext
    automake
    autoreconfHook
    pkg-config
    flex
    bison
    imake
    which
  ];

  buildInputs = [ libX11 libXext libXpm xorgproto imlib2Full ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" "DESTDIR=$out" ];

 #preConfigure = ''
 #  # Regenerate configure files since they're from automake 1.4
 #
 #
 #  # Fix missing includes
 #  #for file in src/*.c src/*.h; do
 #  #  substituteInPlace $file --replace '<X11/xpm.h>' '<X11/xpm.h>'
 #  #done
 #'';

  buildPhase = ''
    runHook preBuild
    #autoupdate --force
    #aclocal
    #autoconf --force
    #automake --foreign --add-missing
    ./configure --prefix=/usr
    make
    runHook postBuild
  '';

  #configureFlags = [
  #  "--with-imagedir=${placeholder "out"}/share/qvwm/images"
  #  "--with-sounddir=${placeholder "out"}/share/qvwm/sounds"
  #];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  mkdir -p $out/share/qvwm/{images,sounds,rc}
 #
 #  # Install binary
 #  cp src/qvwm $out/bin/
 #
 #  # Install data files
 #  cp -r images/* $out/share/qvwm/images/ 2>/dev/null || true
 #  cp -r sounds/* $out/share/qvwm/sounds/ 2>/dev/null || true
 #  cp -r rc/* $out/share/qvwm/rc/ 2>/dev/null || true
 #
 #  # Install documentation
 #  mkdir -p $out/share/man/man1
 #  cp man/qvwm.1 $out/share/man/man1/ 2>/dev/null || true
 #
 #  runHook postInstall
 #'';

  installPhase = ''
    runHook preInstall
    make install
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
