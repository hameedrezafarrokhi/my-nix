{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "rwm";
  version = "2023-01-01";

  src = fetchFromGitHub {
    owner = "ColleagueRiley";
    repo = "RWM";
    rev = "main";
    hash = "sha256-vJLRXxN6mZnHLT3oRZuH3jNcZBeaxuWq9YnBmQ947kg=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 ];

  buildPhase = ''
    gcc rwm.c -lX11 -O3 -o rwm
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp rwm $out/bin/
    strip $out/bin/rwm
  '';

  meta = with lib; {
    homepage = "https://github.com/ColleagueRiley/RWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rwm";
  };
}
