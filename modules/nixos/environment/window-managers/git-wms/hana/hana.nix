{ lib,
  stdenv,
  fetchFromGitHub,
  zig,
  pkg-config,
  cairo,
  pango,
  glib,
  wayland,
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
  gtk3,
  harfbuzz,
  freetype,
  fontconfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hana";
  version = "2026-07-03";

  src = fetchFromGitHub {
    owner = "hana-wm";
    repo = "hana";
    rev = "410d7eb28f5eb4aa001a141f3ca3a1ca52ea2e02";
    sha256 = "1faz5v4k141nxj0ljn3mn3sway7ysvmm4ljax00jdsgai6c8ygkg";
  };

  nativeBuildInputs = [ zig pkg-config ];

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
    cairo
    pango
    glib
    wayland
    gtk3
    harfbuzz
    freetype
    fontconfig
  ];

 #buildPhase = ''
 #  runHook preBuild
 #  zig build --global-cache-dir $(pwd)/.cache --prefix $out
 #  runHook postBuild
 #'';
 #doCheck = false;

  meta = {
    description = "A dynamic tiling compositor";
    homepage = "https://github.com/hana-wm/hana";
    license = lib.licenses.mit;
    mainProgram = "hana";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ /* your name */ ];
  };
})
