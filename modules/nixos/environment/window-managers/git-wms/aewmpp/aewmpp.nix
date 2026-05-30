{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  libX11,
  libXext,
}:

stdenv.mkDerivation rec {
  pname = "aewmpp";
  version = "2014-01-01";

  src = fetchFromGitHub {
    owner = "frankhale";
    repo = "aewmpp";
    rev = "master";
    hash = "sha256-cHB5idqzQ6cQMhjTmkU0MhTwlCjR1e7nrMZ00iGiOVI=";
  };

  nativeBuildInputs = [ clang ];

  buildInputs = [ libX11 libXext ];

  makeFlags = [ "prefix=$(out)" ];

  installPhase = ''
    mkdir -p $out/bin
    install -s aewm++ $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/frankhale/aewmpp";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "aewmpp";
  };
}
