{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  gcc,
  pkg-config
}:

stdenv.mkDerivation rec {
  pname = "nyancat";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "klange";
    repo = "nyancat";
   #rev = "master";
    tag = version;
    hash = "sha256-M/lZLvgx1lQb45TKmEfh06m6RfVE9M1Q7gGz30u16NU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ ncurses ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    cp src/nyancat $out/bin/nyancat
    gzip -9 -c < nyancat.1 > $out/share/man/man1/nyancat.1.gz
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/klange/nyancat";
    description = "Nyancat";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
