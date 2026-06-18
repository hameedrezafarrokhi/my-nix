{
  lib,
  stdenv,
  fetchurl,
  libX11,
  libXft,
  autoconf,
  autoreconfHook,
  automake,
  libtool,
  pkg-config,
  flex,
  gcc13,
}:

stdenv.mkDerivation rec {
  pname = "windwm";
  version = "1.5";

  src = fetchurl {
    url = "https://sourceforge.net/projects/${pname}/files/wind-${version}.tar.gz";
    hash = "sha256-dmAd8TbdyT9YQXEfVAY3L+FXp/OG7pK1SAjqo0uwXFw=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    autoreconfHook
    libtool
    flex
    gcc13
  ];

  buildInputs = [ libX11 libXft ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=$(out)"
 #];

  buildPhase = ''
    runHook preBuild

    autoupdate --force
    #aclocal
    #automake --foreign --add-missing
    autoconf --force
    #./configure --prefix=$out --mandir=$out/share/man

    #mv wind.h wind.h.temp
    #autoreconf -fiv
    #./configure --prefix=$out --mandir=$(out)/share/man

    make V=0

    runHook postBuild
  '';

  installPhase = ''
    #make DESTDIR="$out" install
    make install
  '';

  meta = with lib; {
    homepage = "http://windwm.sourceforge.net/";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "windwm";
  };
}
