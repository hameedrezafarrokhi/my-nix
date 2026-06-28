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
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "legacywm";
  version = "2025-12-31";

  src = fetchFromGitHub {
    owner = "gccgnu";
    repo = "lwm";
   #rev = "main";
    rev = "79ca7506adb29223b6832f93ebc2a5faece62ece";
    sha256 = "1xyci2sjcz34a9gvkasqhfsf2hafmhbkms7mfqcjhbr2576wma5i";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "lwm.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} lwm.c";


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

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp legacywm $out/bin/legacywm
 #
 #  runHook postInstall
 #'';

  postInstall = ''
    cp -f $out/bin/lwm $out/bin/legacywm
    rm -f $out/bin/lwm
  '';

  meta = with lib; {
    homepage = "https://github.com/gccgnu/lwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "legacywm";
  };
}
