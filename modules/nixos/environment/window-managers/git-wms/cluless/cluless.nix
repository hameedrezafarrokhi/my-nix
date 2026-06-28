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
  pname = "cluless";
  version = "2024-09-07";

  src = fetchFromGitHub {
    owner = "lycuid";
    repo = "cluless";
   #rev = "master";
    rev = "42d7aa37b599b194c58bb5e92f431fa96c5b22c2";
    sha256 = "0b0ylr1sfgqfs9xnq8sgwy0mxg4rklhl1djalfs3rwg9q2sgp43z";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.h";


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
    "DESTDIR=${placeholder "out"}"
    "BINPREFIX=/bin"
    "MANPREFIX=/share/man/man1"
  ];

  preInstall = ''
    mkdir -p $out/bin $out/bin $out/share/man/man1
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin $out/bin $out/share/man/man1
 #  cp src/cluless/cluless $out/bin/cluless
 #  cp cluless.1.tmpl $out/share/man/man1/cluless.1
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/lycuid/cluless";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "cluless";
  };
}
