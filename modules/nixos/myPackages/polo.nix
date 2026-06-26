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

  gtk3,
  vala,
  gdk-pixbuf-xlib,
  vte,
}:

stdenv.mkDerivation rec {
  pname = "polo";
  version = "2024-02-11";

  src = fetchFromGitHub {
    owner = "teejee2008";
    repo = "polo";
   #rev = "master";
    rev = "27215601071bc1b6cb8831f819151577b5070c96";
    sha256 = "1ay3m767yk7akfb4ippqd4n9p144187jb019fgaz2zi3zaw97v71";
  };

  nativeBuildInputs = [
    pkg-config
    vala
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

    gtk3
    vala
    gdk-pixbuf-xlib
    vte
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
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/teejee2008/polo";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "polo";
  };
}
