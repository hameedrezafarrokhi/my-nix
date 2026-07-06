{
  lib,
  stdenv,
  fetchFromGitea,
  buildNimPackage,
  fetchFromGitHub,
  nim2,
  nim-unwrapped-2_0,
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

let

  toml-nim = fetchFromGitHub {
    owner = "NimParsers";
    repo = "parsetoml";
    rev = "d297f5a81be2472905d367aa675dcbbca6e7a5d2";
    sha256 = "0dax2bfzwygx4142qywib9n4z3h3cvvr5dy2h3jy35iizg16iqka";
  };

in

#stdenv.mkDerivation (finalAttrs: {
buildNimPackage (finalAttrs: {
  pname = "vertex";
  version = "2024-08-13";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "anhsirk0";
    repo = "vertex";
    rev = "80e4ddd156ac283b5623fd1841168ec11df7e4f7";
    sha256 = "1jkwb5npiafak1116kg6cxz0il8vrpgh3ykpmcmlhspszgp1mrq7";
  };

  nativeBuildInputs = [
    pkg-config
    nim2
    nim-unwrapped-2_0.out
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

 #buildPhase = ''
 #  HOME=$TMPDIR
 #  nim --run -p:${toml-nim}/ c -d:release src/vertex.nim
 #'';
 #
 #installPhase = ''
 #  mkdir -p $out/bin $out/share/vertex
 #  cp vertex $out/bin/vertex
 #  cp config.toml $out/share/vertex/config.toml
 #'';

 #nimFlags = [
 #  "-d:release"
 # #"-p:${x11-nim}/"
 #  "src/vertex.nim"
 #];

  requiredNimVersion = 2;

  meta = {
    description = "hot corners for x11";
    homepage = "https://codeberg.org/anhsirk0/vertex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "vertex";
    platforms = lib.platforms.linux;
  };
})
