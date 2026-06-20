{
  lib,
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

  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "karuiwm";
  version = "2015-12-12";

  src = fetchFromGitHub {
    owner = "roosemberth";
    repo = "karuiwm";
   #rev = "master";
   #rev = "a88f808f1c078a0c1b1da91c56ebc11b6224a89c";
   #sha256 = "0xbri045hrnywnksajz4wlf0r11bch21dvi845dpljgcmd1dixk0";

    rev = "legacy";
    hash = "sha256-uPS6eXB93yK5VfbrCK9drn9TtEZx7SO04KXYClmjRWE=";
  };

  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  preBuild = ''
    cp config.def.h config.h
    mkdir -p $out/bin
  '';

  nativeBuildInputs = [
    pkg-config
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
    #"CC=${stdenv.cc.targetPrefix}cc"
    #"INSTALLDIR=${placeholder "out"}/bin"
     "PREFIX=${placeholder "out"}"
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #  make
 #
 #  runHook postBuild
 #'';

  meta = with lib; {
    homepage = "https://github.com/roosemberth/karuiwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "karuiwm";
  };
}
