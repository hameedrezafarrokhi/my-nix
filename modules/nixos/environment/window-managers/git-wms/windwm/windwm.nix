{
  lib,
  stdenv,
  fetchurl,
  libX11,
  libXft,
  autoconf,
  automake,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "windwm";
  version = "1.5";

  src = fetchurl {
    url = "https://sourceforge.net/projects/${pname}/files/wind-${version}.tar.gz";
    hash = "sha256-dmAd8TbdyT9YQXEfVAY3L+FXp/OG7pK1SAjqo0uwXFw=";
  };

  nativeBuildInputs = [ pkg-config autoconf automake ];

  buildInputs = [ libX11 libXft ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  buildPhase = ''
    mv wind.h wind.h.temp
    autoreconf -fiv
    ./configure --prefix=$(out)/ --mandir=$(out)/share/man
    #mv wind.h.temp wind.h
    touch wind.h
    ls
    pwd
    make V=0
  '';

  installPhase = ''
    make DESTDIR="$out" install
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
