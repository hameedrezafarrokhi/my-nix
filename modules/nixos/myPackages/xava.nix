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

  fftwFloat,
  iniparser,

  # Input
  alsa-lib,
  libpulseaudio,
  pipewire,
  portaudio,
  sndio,

  # Output
  SDL2,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wayland-utils,

  # Graphics API
  cairo,
  glew,
  libGL,

  # Misc
  curl,
  dbus,
  expat, # Might be a nixpkgs bug idfk
  taglib,
  zlib,

  clang,
  cmake,
  git, # Not sure if it's needed

  # For building icons
  imagemagick,
  librsvg,

  # For debugging
  clang-tools,

  # Patching
  makeWrapper,

}:

stdenv.mkDerivation rec {
  pname = "xava";
  version = "2026-03-08";

  src = fetchFromGitHub {
    owner = "nikp123";
    repo = "xava";
    rev = "de410ae8c0da4265e41a7242501d701e5d741842";
    sha256 = "1pjgv5fx7jz4dzzl8wdh745g8zswaiik83gczzqq8j4bwcsrvvs3";
  };

  nativeBuildInputs = [
    pkg-config
    clang
    cmake
    git # Not sure if it's needed

    # For building icons
    imagemagick
    librsvg

    # For debugging
    clang-tools

    # Patching
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

    fftwFloat
    iniparser

    # Input
    alsa-lib
    libpulseaudio
    pipewire
    portaudio
    sndio

    # Output
    SDL2
    wayland
    wayland-protocols
    wayland-scanner
    wayland-utils

    # Graphics API
    cairo
    glew
    libGL

    # Misc
    curl
    dbus
    expat # Might be a nixpkgs bug idfk
    taglib
    zlib
  ];

  cmakeFlags = [
    "CMAKE_SKIP_BUILD_RPATH=true"
    "-DNIX_BUILDER=ON"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
  ];

  postPatch = ''
    substituteInPlace src/cmake/install_and_configure.cmake \
      --replace 'convert -size' 'magick -size'
  '';

  postInstall = ''
    wrapProgram $out/bin/xava \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  CARGO_FEATURE_USE_SYSTEM_LIBS = "1";

  meta = with lib; {
    homepage = "https://github.com/nikp123/xava";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xava";
  };
}
