{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXmu,
  libXpm,
  libXrandr,
  autoconf,
  autoreconfHook,
  automake,
  gettext,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "blackbox";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "bbidulock";
    repo = "blackboxwm";
   #rev = "master";
    rev = "22c0762237d08d04dedd13bcfc4a442a7e5a634d";
    sha256 = "1nkdcvcw87ch18704jmmsmkijwxqsswx3m56mkhv3vfvir4xbyyx";
  };

  nativeBuildInputs = [
    libtool
    autoconf
    autoreconfHook
    gettext
    automake
    pkg-config
  ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libXmu
    libXpm
    autoconf
    gettext
    automake
    libtool
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p m4
    autoconf --force
    make
    runHook postBuild
  '';

  meta = {
    homepage = "http://www.github.com/bbidulock/blackboxwm";
    description = " ";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
  };
}
