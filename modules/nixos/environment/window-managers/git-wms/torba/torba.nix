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

}:

stdenv.mkDerivation rec {
  pname = "torba";
  version = "2011-02-08";

  src = fetchFromGitHub {
    owner = "berke";
    repo = "torba";
   #rev = "master";
    rev = "1a4df1bdd00d90475a2ff08402f87c1942aedde7";
    sha256 = "1m259q6ylvxjsqislhkrlics23l70jc7yyx6ksvmc05dlcag4zq3";
  };

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

    cd linux
    make

    runHook postBuild
  '';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/berke/torba";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "torba";
  };
}
