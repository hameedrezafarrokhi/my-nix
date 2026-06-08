{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gcc,
  leif,
  libX11,
  xcb-proto,
  xcbproto,
  libxcb-util,
  libxcb-keysyms,
  libxcb-cursor,
  libxcb-wm,
  libxcb,
  libxcb-image,
  libxcb-render-util,
  libxcb-errors,
  libGL,
  glfw,
  cglm,
  fontconfig,
  libclipboard,
  makeWrapper,
  freetype,
 #inter,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "ticalc";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "cococry";
    repo = "ticalc";
    rev = "main";
    hash = "sha256-X5B5ppZ5x7RWg9FPQTiBXsIA7pKveUH5OoBPx2XjIJ4=";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  nativeBuildInputs = [
    pkg-config
    gcc
    makeWrapper
  ];

  buildInputs = [
    leif
    glfw
    cglm
    libclipboard
    libX11
    xcb-proto
    xcbproto
    libxcb-util
    libxcb-keysyms
    libxcb-cursor
    libxcb-wm
    libxcb
    libxcb-image
    libxcb-render-util
    libxcb-errors
    fontconfig
    freetype
   #inter
  ];

  buildPhase = ''
    $CC -o ticalc *.c $CFLAGS -lglfw -lleif -lclipboard -lm -lGL
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 ticalc $out/bin/
    mkdir -p $out/share/applications $out/share/icons
    cp ticalc.desktop $out/share/applications/
    cp -r logo $out/share/icons/ticalc
  '';

    #wrapProgram $out/bin/ticalc \
    #  --run 'mkdir -p ~/.leif/assets/fonts && \
    #         cp -r ${inter}/truetype/inter.ttf ~/.leif/assets/fonts/ 2>/dev/null || true'

  postInstall = ''
    wrapProgram $out/bin/ticalc \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = {
    homepage = "https://github.com/cococry/ticalc";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
