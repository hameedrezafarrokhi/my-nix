{
  lib,
  stdenv,
  fetchurl,
  libjpeg,
  libX11,
  libXext,
  libXmu,
  libXpm,
  libXrandr,
  breezy,
  cmake,
  m4,
  bison,
  doxygen,
  flex,
}:

stdenv.mkDerivation rec {
  pname = "ctwm";
  version = "4.1.0";

  src = fetchurl {
    url = "https://www.ctwm.org/dist/ctwm-${version}.tar.gz";
    hash = "sha256-ifbyHiacZBGV5rOf6ARTf8556w34IbGmlpOa6rdETKo=";
  };

  nativeBuildInputs = [
    cmake
    bison
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libXmu
    libXpm
    libjpeg
    breezy
    m4
    doxygen
    flex
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
  ];

  buildPhase = ''
    cmake -DCMAKE_INSTALL_PREFIX=$out ../
  '';

  meta = {
    homepage = "http://ctwm.org/";
    description = "Claude's Tab Window Manager";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
  };
}
