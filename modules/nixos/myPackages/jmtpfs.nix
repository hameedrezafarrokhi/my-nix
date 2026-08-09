{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libmtp,
  file,
  fuse,
}:

stdenv.mkDerivation rec {
  pname = "jmtpfs";
  version = "2013-11-25";

  src = fetchFromGitHub {
    owner = "JasonFerrara";
    repo = "jmtpfs";
    rev = "928fb8f2eec34232e3b2cecc121195caa8865e15";
    sha256 = "1pm68agkhrwgrplrfrnbwdcvx5lrivdmqw8pb5gdmm3xppnryji1";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libmtp
    file
    fuse
  ];

  meta = with lib; {
    homepage = "https://github.com/JasonFerrara/jmtpfs";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "jmtpfs";
  };
}
