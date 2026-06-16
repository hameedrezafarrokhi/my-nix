{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  pkg-config,
  go,
  buildGoModule,
}:

buildGoModule rec {
  pname = "wingo";
  version = "2026-05-18";

  src = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "wingo";
   #rev = "master";
    rev = "33b154361587e65ec35d4499f1cc487835d0ab48";
    sha256 = "0hx61qdfx1xi3jkzdq144kq6ca8l5rpfviz1gn3blpnckrcxfgyn";
  };

  vendorHash = "sha256-OYyWLn+QuXVyiZtzPrcKMPepqAN1qXV+xZYX6Vj2jS4=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 ];

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mkdir -p $out/share/wingo
    cp -r data/* $out/share/wingo/
    mkdir -p $out/etc/xdg/wingo
    cp config/* $out/etc/xdg/wingo/
  '';

  meta = with lib; {
    homepage = "https://github.com/BurntSushi/wingo";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wingo";
  };
}
