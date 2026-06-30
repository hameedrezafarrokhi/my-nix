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

}:

stdenv.mkDerivation rec {
  pname = "wmsquared";
  version = "2026-06-01";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "xtn59";
    repo = "wmsquared";
    rev = "06a7893c6c23094404f4984932049ed09ea1156f";
    hash = "sha256-sEKOVyqnFlwItgwNtp+/raudiKbxq3UCLb1GpVAkxfg=";
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp wm $out/bin/wmsquared
    mkdir -p $out/share
    cp wmrc $out/share/wmrc

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/xtn59/wmsquared";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wmsquared";
  };
}
