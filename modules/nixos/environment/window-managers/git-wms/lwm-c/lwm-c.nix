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
  conf ? null,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "lwm";
  version = "2026-06-08";

  src = fetchFromGitHub {
    owner = "miublue";
    repo = "lwm";
   #rev = "main";
    rev = "1be19e5b7a1934e0bb4c6ac278867d25d380e60c";
    sha256 = "0qa8yw76qirvvjmis8wqw3wdg4ravijlnx0bfr9vfzvl4wx6zfmh";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


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
    "CC=${gcc13Stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp lwm $out/bin/lwm
 #
 #  runHook postInstall
 #'';

  postInstall = ''
    cp -f $out/bin/lwm $out/bin/lwm-c
    rm -f $out/bin/lwm
  '';

  meta = with lib; {
    homepage = "https://github.com/miublue/lwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "lwm";
  };
}
