{
  lib,
  stdenv,
  fetchurl,
  libX11,

}:

stdenv.mkDerivation rec {
  pname = "karmen";
  version = "0.15";

  src = fetchurl {
    url = "https://sourceforge.net/projects/${pname}/files/${pname}/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-Kbf6HaWB06Itbbgs5ra245a+m2sK8gkbjAQwQObiuYA=";
  };

  buildInputs = [ libX11 ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  buildPhase = ''
    sed -i 's/LICENSE //' Makefile.in
    ./configure --prefix=$(out)
    make
    make DESTDIR="$out" install
  '';

  installPhase = ''
    mkdir -p $out/bin
  '';

  meta = with lib; {
    homepage = "https://karmen.sourceforge.net/";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "karmen";
  };
}
