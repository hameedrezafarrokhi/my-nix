{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libX11,
  libXpm,
  libXext,
  libXft,
  fontconfig,
  freetype,
}:

stdenv.mkDerivation rec {
  pname = "fowm";
  version = "2026-05-15";

  src = fetchFromGitHub {
    owner = "chrispurnell";
    repo = "fowm";
    rev = "main";
    hash = "sha256-x8IEIcp6SAJUMX3dxyviUbIf1j2RoeRyLOjdNt8rLkk=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXpm
    libXext
    libXft
    fontconfig
    freetype
  ];

  makeFlags = [ "CC=gcc" "XFT=1" ];

  installPhase = ''
    mkdir -p $out/bin
    cp fowm $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/chrispurnell/fowm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fowm";
  };
}
