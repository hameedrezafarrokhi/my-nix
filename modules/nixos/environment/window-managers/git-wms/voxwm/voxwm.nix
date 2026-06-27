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
  pname = "voxwm";
  version = "2026-06-07";

  src = fetchFromGitHub {
    owner = "vorzi";
    repo = "voxwm";
   #rev = "main";
    rev = "aa4a8f03fd1e06f52e2c970509a4910ac5dca2e8";
    sha256 = "01mryxdl9yf32by7zvykqd461kxyiq5mdibzq2ardfsglvflzvdg";
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
   #"PREFIX=$(out)"
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp wm $out/bin/voxwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/vorzi/voxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "voxwm";
  };
}
