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

  clang-tools,
  clang,
  automake,
  autoconf,
  libtool,

  envsubst,
  cairo,
  pulseaudio,
  harfbuzz,
  alsa-lib,
}:

stdenv.mkDerivation rec {
  pname = "bspwmbar";
  version = "2024-02-21";

  src = fetchFromGitHub {
    owner = "odknt";
    repo = "bspwmbar";
   #rev = "main";
    rev = "6856e7b4eb1c5f8f24236f7ef7e481ee4d8535e1";
    sha256 = "05nqgj7pibg78lakr2gg8jwdma2svl9n22jf7kn6nn7lvw22wa4y";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";


  nativeBuildInputs = [
    pkg-config
    clang-tools
    clang
    automake
    autoconf
    libtool
    envsubst
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

    cairo
    pulseaudio
    harfbuzz
    alsa-lib
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
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
 #  mkdir -p $out/bin
 #  cp bspwmbar $out/bin/bspwmbar
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/odknt/bspwmbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bspwmbar";
  };
}
