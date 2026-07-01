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
  sol2,
  lua5_4,
  cmake,

}:

stdenv.mkDerivation rec {
  pname = "PaperBar";
  version = "2026-01-27";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "JJoeDev";
    repo = "PaperBar";
    rev = "ce055d5bc07f7863370d2ae5fda799bf836de68f";
    hash = "sha256-aJaD5vU2GChSu/07BZxmA8ezfOvIG2+e+eRDCXz5Mas=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
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
    sol2
    lua5_4

  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp PaperBar $out/bin/PaperBar
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/JJoeDev/PaperBar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "PaperBar";
  };
}
