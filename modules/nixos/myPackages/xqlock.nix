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

  cmake,

  kdePackages,
}:

stdenv.mkDerivation rec {
  pname = "xqlock";
  version = "2026-01-03";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "realroot";
    repo = "xqlock";
    rev = "9e452d896802ad3133cdbed8e99663b50ef3eba3";
    sha256 = "1rx20cg416ni0km8lvqaq6dr6k78qimyaczs5xfiml15bw9ibnwr";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    kdePackages.wrapQtAppsHook
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

    kdePackages.qtbase
    kdePackages.qtquick3d

  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #  zig build --release=safe
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp xqlock $out/bin/xqlock
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/realroot/xqlock";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xqlock";
  };
}
