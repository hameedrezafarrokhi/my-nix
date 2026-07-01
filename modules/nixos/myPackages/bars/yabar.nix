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

  cairo,
  gdk-pixbuf,
  gdk-pixbuf-xlib,
  libconfig,
  pango,
  docbook_xsl,
  alsa-lib,
  wirelesstools,
  asciidoc,
  libxslt,
  makeWrapper,
  libxml2,
  playerctl,

}:

stdenv.mkDerivation rec {
  pname = "yabar";
  version = "2019-03-28";

  src = fetchFromGitHub {
    owner = "geokb";
    repo = "yabar";
   #rev = "main";
    rev = "a0d3fdfed992149b741eb8fcf53f02b5d1a6142e";
    sha256 = "01igivi2s96xxgy08cbhmvqcfq15rckh258gjy1iygkc8fzzlxjw";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
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
    gdk-pixbuf
    gdk-pixbuf-xlib
    libconfig
    pango
    docbook_xsl
    alsa-lib
    wirelesstools
    asciidoc
    libxslt
    makeWrapper
    libxml2
    playerctl

  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    make yabar
    make docs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp yabar $out/bin/yabar

    mkdir -p $out/share/man/man1
    cp doc/yabar.1 $out/share/man/man1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/geokb/yabar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "yabar";
  };
}
