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
  git,
  libxtst,

}:

stdenv.mkDerivation rec {
  pname = "sdorfehs";
  version = "2026-03-02";

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "sdorfehs";
    rev = "21072a06f840f1f7ae01b9e004b5a9fc9f207763";
    sha256 = "1ycs8x0lnsm8jaxy70z1jgrgn3xrabqp1yh54yq2zl74silsakyz";
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
    git
    libxtst
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];


 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp sdorfehs $out/bin/sdorfehs
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/jcs/sdorfehs";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sdorfehs";
  };
}
