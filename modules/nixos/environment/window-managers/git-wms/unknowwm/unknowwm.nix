{
  lib,
 #stdenv,
  gcc13Stdenv,
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
  gcc13,
  gnumake42,

  writeText,
  conf ? null,

  installShellFiles,
}:

#stdenv.mkDerivation rec {
gcc13Stdenv.mkDerivation rec {
  pname = "unknowwm";
  version = "2023-05-14";

  src = fetchFromGitHub {
    owner = "J-CITY";
    repo = "unknowwm";
   #rev = "master";
   #rev = "7b726c40b6c6ceca60310a46450382c0c56f1085";
   #sha256 = "1z1820fzfaf6mb77wxhz2gmagbfjzj68fgqybl3if3gpazl9wjdq";

    rev = "animations";
    hash = "sha256-q4JYDRtWM022SD9bmxiJ23y69q4/mP0Ap7CRfWBIttc=";
  };

 #postPatch =
 #  let
 #    configFile =
 #      if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
 #  in
 #  lib.optionalString (conf != null) "cp ${configFile} config.h";


  nativeBuildInputs = [
    pkg-config
    installShellFiles
    gcc13
    gnumake42
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
    gcc13
    gnumake42
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
   #"CC=${stdenv.cc.targetPrefix}g++"
    "GCC=${gcc13}/bin/g++"
 #  "X11INC="
 #  "X11LIB="

 #  "INCS=-I. \
 #    -I${lib.getDev freetype}/include/freetype2"

 #  "LIBS=-lX11 -lXft -lfontconfig -lXrandr -lfreetype -lpthread -lz"

  ];

# installFlags = [
#   "DESTDIR="
#   #"PREFIX="
# ];

 #postInstall = ''
 #  if [ -f wm.1 ]; then
 #    installManPage wm.1
 #  fi
 #'';

  buildPhase = ''
    runHook preBuild

    #${gnumake42}/bin/make WMNAME=unknowwm

    make WMNAME=unknowwm

    #${gcc13}/bin/g++ \
    #  -std=c++17
    #  -Os \
    #  -I. \
    #  -I${freetype.dev}/include/freetype2 \
    #  *.cpp \
    #  -o wm \
    #  -lX11 -lXft -lfontconfig -lXrandr -lfreetype -lpthread -lz

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/J-CITY/unknowwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "unknowwm";
  };
}
