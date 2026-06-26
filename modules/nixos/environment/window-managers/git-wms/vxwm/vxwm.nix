{
  lib,
  stdenv,
  fetchFromGitea,

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
  modules ? null,
}:

stdenv.mkDerivation rec {
  pname = "vxwm";
  version = "2020-10-21";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wh1tepearl";
    repo = "vxwm";
    rev = "b2ec2558895b9a55c18682a8e6dab3bdcca95683";
    sha256 = "0q7jg8hr3l4hapkc1l6p8grik16rkh7pmgb4iw6jph7qbpqm582v";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
      moduleFile =
        if lib.isDerivation modules || builtins.isPath modules then modules else writeText "modules.def.h" modules;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h"
    + " \n " +
    lib.optionalString (modules != null) "cp ${moduleFile} modules.def.h"
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

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/wh1tepearl/vxwm  ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "vxwm";
  };
}
