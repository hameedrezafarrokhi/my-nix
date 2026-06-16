{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libxinerama,
  libxrandr,
  libxcb,
  libxcb-util,
  libxcb-keysyms,
  libxcb-wm,
  libxcb-cursor,
  libxcb-render-util,
  libxcb-image,
  libxcb-errors,
  xorgproto,
  libxkbcommon,
  bash,
  gcc,
}:

stdenv.mkDerivation rec {
  pname = "zwm";
  version = "2026-06-14";

  src = fetchFromGitHub {
    owner = "yazeed1s";
    repo = "zwm";
   #rev = "main";
    rev = "a8b2e37bcaff65b58054ababb6edbf1947a5df15";
    sha256 = "0a86ma2hz0mc0dz368qq7m06ngimawllr958rppni9sf6ds6djwv";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [
    libX11
    libxinerama
    libxrandr
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
    libxcb-cursor
    libxcb-render-util
    libxcb-image
    libxcb-errors
    xorgproto
    libxkbcommon
    bash
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    homepage = "https://github.com/yazeed1s/zwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zwm";
  };
}
