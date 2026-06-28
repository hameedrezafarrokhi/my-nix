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

 #gprbuild,
 #gnat,
  gnatPackages,
  gnat,

  libGLX,
  libGL,

  egl-x11,

  xorgproto,

  yasm,
}:

stdenv.mkDerivation rec {
  pname = "troodon";
  version = "2021-04-14";

  src = fetchFromGitHub {
    owner = "docandrew";
    repo = "troodon";
   #rev = "master";
    rev = "9240611708f92ffb5491fa677bffb6ecac58a51e";
    sha256 = "12zr54wpavzyjbj2yn0liby4xfqv39wab71811i2rxbk7700c8cf";
  };

  nativeBuildInputs = [
    pkg-config
   #gprbuild
    gnatPackages.gprbuild
    gnatPackages.gnat
    gnat
    yasm
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

    libGLX
    libGL

    egl-x11

    xorgproto
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp obj/troodon $out/bin/troodon

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/docandrew/troodon";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "troodon";
  };
}
