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

  meson,
  ninja,
  clang,
  clang-tools,
  objfw,
  fltk,
  cmake,

}:

stdenv.mkDerivation rec {
  pname = "basketcase";
  version = "2026-04-26";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "arm32x";
    repo = "basketcase";
    rev = "f01e2a4b87bd12c9bf8f40f4831e68ad53a2d051";
    hash = "sha256-Kf1KClgJZfOXTFQjtadz7KYTzxMdz6DRMgPjRufHrJM=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    clang
    clang-tools
    objfw
    fltk
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

    objfw
    fltk
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
 #  cp basketcase $out/bin/basketcase
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/arm32x/basketcase";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "basketcase";
  };
}
