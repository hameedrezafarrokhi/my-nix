{
  lib,
  gcc,
  stdenv,
  fetchFromGitHub,
  libXrandr,
  libXext,
  libX11,
  libXi,
  libXfixes,
}:

stdenv.mkDerivation rec {
  pname = "gloom";
 #version = "2016.01.01";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "whitelynx";
    repo = "gloom";

    tag = version;
    hash = "sha256-S0E0i9mzM983hH7/PjjnMGsvFt0pWGEdhS9mjXwWHp4=";

   #rev = "master";
   #hash = "sha256-S0E0i9mzM983hH7/PjjnMGsvFt0pWGEdhS9mjXwWHp4=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [
    libXrandr
    libXext
    libX11
    libXi
    libXfixes
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  buildPhase = ''
    $CC -w src/gloom.c -lX11 -lXext -lXrandr -lXfixes -lXi -o gloom
  '';

  meta = {
    homepage = "https://github.com/whitelynx/gloom";
    description = "";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
