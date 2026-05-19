{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcb,
  xcbutil,
  xcbutilwm,
  libconfig,
  pcre,
}:

stdenv.mkDerivation rec {
  pname = "custard";
  version = "2020-01-01";

  src = fetchFromGitHub {
    owner = "comfies";
    repo = "custard";
    rev = "master";
    hash = "sha256-SirqsjON7VPzUIYYzuciDwyc5IjFZjEgzinE4m183Ns=";
  };

  buildInputs = [ libxcb xcbutil xcbutilwm libconfig pcre ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  meta = with lib; {
    homepage = "https://github.com/comfies/custard";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "custard";
  };
}
