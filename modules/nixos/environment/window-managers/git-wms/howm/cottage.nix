{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
}:

stdenv.mkDerivation rec {
  pname = "cottage";
  version = "2017-09-15";

  src = fetchFromGitHub {
    owner = "HarveyHunt";
    repo = "cottage";
   #rev = "master";
    rev = "00de4a6041e3a0b6f1c25731290fbe066387e632";
    sha256 = "1y8r9as1c40n4zcqbn312gg9pq719i0pcy8g15jb7xsrq21lan1m";
  };

  nativeBuildInputs = [ clang ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/HarveyHunt/cottage";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "cottage";
  };
}
