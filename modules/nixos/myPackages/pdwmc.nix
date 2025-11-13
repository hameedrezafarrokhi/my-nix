{
  lib,
  stdenv,
 #fetchurl,
 #fetchTarball,
  libX11,
  libXinerama,
  libXft,
  writeText,
  patches ? [ ],
  conf ? null,
  # update script dependencies
  gitUpdater,

  imlib2,
  libxcb,
  xcbutil,
  xcbutilwm,
  xcbutilkeysyms,
  dwmblocks,
  python3,

  inputs,
}:

stdenv.mkDerivation rec {
  pname = "pdwmc";
  version = "6.0";

  src = inputs.pdwmc;

  buildInputs = [
    libX11
    libXinerama
    libXft

    imlib2
    libxcb
    xcbutil
    xcbutilwm
    xcbutilkeysyms
    dwmblocks
    python3
    python3.pycparser
  ];
  #sed -i "s@release@$out@" Makefile
  #sed -i "s@/usr/share/xsessions@$out@" Makefile
  prePatch = ''
    sed -i "s@/usr@$out@" Makefile
  '';

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  meta = with lib; {
    homepage = "https://github.com/r0-zero/pdwmc/";
    description = "aaa";
    longDescription = ''
    aaaa
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ neonfuz ];
    platforms = platforms.all;
    mainProgram = "pdwmc";
  };
}
