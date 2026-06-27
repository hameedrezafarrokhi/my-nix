{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

 #autoconf,
 #automake,
 #libtool,

}:

stdenv.mkDerivation rec {
  pname = "scrotwm";
  version = "2009-03-05";

  src = fetchFromGitHub {
    owner = "rennhak";
    repo = "scrotwm";
   #rev = "master";
    rev = "87efc3565b641f679598210f5bbf73b7458ad89d";
    sha256 = "1ybyp485jwmd8c26a59wjh3c03dchgn75vz7l7kp956fc90b2q19";
  };

  nativeBuildInputs = [
    pkg-config
   #autoconf
   #automake
   #libtool
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  preConfigure = ''
    cd linux
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/man/man1

    cp scrotwm $out/bin/scrotwm
    cp libswmhack.so.0.0 $out/lib/
    cp ../man/scrotwm.1 $out/share/man/man1/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/rennhak/scrotwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "scrotwm";
  };
}
