{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "2D_supermario";
  version = "2025-05-15";

  src = fetchFromGitHub {
    owner = "kimhanna3";
    repo = "2D_supermario";
    rev = "c6a8879db2463ae5d438ae9976478833d9a60d68";
    sha256 = "0ri4s060g8l6pb2kavb8xx7c6cmfzxdqsr8aik16iqsb3nw3b60a";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ ncurses ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp game $out/bin/2dsupermario

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/kimhanna3/2D_supermario";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "2D_supermario";
  };
}
