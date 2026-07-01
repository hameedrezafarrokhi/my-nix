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

  pango,
  cairo,

  bionic,
  hpx,
  picolibc,
  scs,

}:

gcc13Stdenv.mkDerivation rec {
  pname = "oxbar";
  version = "2024-12-06";

  src = fetchFromGitHub {
    owner = "ryanflannery";
    repo = "oxbar";
   #rev = "main";
    rev = "41d604ffd2d1f1266e1ef85adda65cc3da044011";
    sha256 = "0z71lrafjyg12vxzbn73c1qav6f7ibabj3pz1qp5iwh5cqs57b4v";
  };

  nativeBuildInputs = [
    pkg-config
    bionic.dev
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
    pango
    cairo
    hpx
    picolibc.dev
    scs

  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];
 #
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
 #  cp oxbar $out/bin/oxbar
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/ryanflannery/oxbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "oxbar";
  };
}
