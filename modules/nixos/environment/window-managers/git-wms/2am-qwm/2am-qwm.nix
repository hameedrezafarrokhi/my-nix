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

  writeText,
  conf ? null,
}:

let

  hfile = ./2am-builder.h;

in

stdenv.mkDerivation rec {
  pname = "2am-qwm";
  version = "2026-01-20";

  src = fetchFromGitHub {
    owner = "kunyukzz";
    repo = "2am-qwm";
   #rev = "main";
    rev = "923175e2d2907f1e982f733a81d4a247ee020d99";
    sha256 = "1ffa4jfc44m6lk65v7046ga06iqmrhz3khwbr89lav9xhkr690bi";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.h"
    + " \n " +
    "rm -f 2am-builder.h && cp -f ${hfile} 2am-builder.h"
    ;


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
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    cc build.c -o build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp -r ${src}/src $out/
    cp -f build $out/2am-qwm

    #cp -f build $out/bin/2am-qwm
    ln -sf $out/2am-qwm $out/bin/2am-qwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/kunyukzz/2am-qwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "2am-qwm";
  };
}
