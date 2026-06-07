{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  pkg-config,
  libayatana-appindicator,
  gtk3,
  fontconfig,
  freetype,
  libXft,
  cairo,
}:

stdenv.mkDerivation rec {
  pname = "traymd";
  version = "2026.06.01";

  src = fetchFromGitHub {
    owner = "rabfulton";
    repo = "TrayMD";
    rev = "master";
    hash = "sha256-FDwV0hnWMFj87dj+RC9bKJsBO2pWUi0xqtuaLRwFb28=";
  };

  nativeBuildInputs = [ pkg-config gcc ];

  buildInputs = [
    libayatana-appindicator
    gtk3
    fontconfig
    cairo
    libXft
    freetype
  ];

  makeFlags = [ "CC:=$(CC)" "PREFIX=$(out)" ];

  meta = {
    homepage = "https://github.com/rabfulton/TrayMD";
    description = "Nyancat";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
