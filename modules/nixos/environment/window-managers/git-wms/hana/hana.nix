{ lib,
  stdenv,
  fetchFromGitHub,
  zig,
  pkg-config,
  cairo,
  pango,
  glib,
  wayland,
  libX11,
  xorg,
  libxkbcommon,
  libxcb,
  libxcb-cursor,
  libxcb-errors,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  gtk3,
  harfbuzz,
  freetype,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hana";
  version = "2026-5-10";

  src = fetchFromGitHub {
    owner = "hana-wm";
    repo = "hana";
    rev = "dev";
    hash = "sha256-ctJSwFzwbL77DGBK9/pJUCO7/cYBia5+QQc8NEtDTTU=";
  };

  nativeBuildInputs = [
    zig
    pkg-config
  ];

  buildInputs = [
    libX11
   #xorg
    libxcb
    libxcb-cursor
    libxcb-errors
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    libxkbcommon
    cairo
    pango
    glib
    wayland
    gtk3
    harfbuzz
    freetype
  ];

  buildPhase = ''
    runHook preBuild
    #zig build -Doptimize=ReleaseFast --prefix $out
    #zig build install --global-cache-dir $(pwd)/.cache --system $PACKAGE_DIR -Dtarget=$       {target} -Doptimize=ReleaseSafe --color off --prefix $out
    #zig build install --global-cache-dir $(pwd)/.cache --system $PACKAGE_DIR -Doptimize=ReleaseSafe --color off --prefix $out
    zig build --global-cache-dir $(pwd)/.cache --prefix $out
    runHook postBuild
  '';

 #zigBuildFlags = [
 #  "--system"
 #];

 #installPhase = ''
 #  runHook preInstall
 #  # zig build --prefix already installed to $out
 #  runHook postInstall
 #'';

  doCheck = false;

 #checkPhase = ''
 #  runHook preCheck
 #  zig build check
 #  runHook postCheck
 #'';

  meta = {
    description = "A dynamic tiling compositor";
    homepage = "https://github.com/hana-wm/hana";
    license = lib.licenses.mit;
    mainProgram = "hana";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ /* your name */ ];
  };
})
