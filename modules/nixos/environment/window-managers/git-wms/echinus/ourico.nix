{
  lib,
  stdenv,
  fetchurl,
  libX11,
  libXft,
  libXrandr,
  libxkbcommon,
  xorgproto,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ourico";
  version = "0.1.7";

  src = fetchurl {
    url = "http://plhk.ru/static/ourico/ourico-${version}.tar.gz";
    hash = "sha256-KTGPUAJoUhbvdUmYmB43Qs+IlS8gh53NPpDThu+R/jI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXft
    libXrandr
    libxkbcommon
    xorgproto
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    "DESTDIR=${placeholder "out"}"
  ];

  meta = with lib; {
    homepage = "http://freshmeat.sourceforge.net/projects/ourico";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ourico";
  };
}
