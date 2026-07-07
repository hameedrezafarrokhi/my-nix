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

  zig_0_15,

  egl-x11,
  egl-wayland,
  libGL,
  libGLX,
  libGLU,
  glew,
  glm,
  wayland,
  wayland-protocols,
  wayland-scanner,
  kdePackages,
  glfw,
}:

stdenv.mkDerivation rec {
  pname = "zowon";
  version = "2026-05-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "imal";
    repo = "zowon";
    rev = "c5f57dec0f6c2632f6c73bb3a1c73eb0590c29c5";
    sha256 = "08j3vl785a3hap6yq249vfcdklv77n1gk3aaxarbpi8sk8x4a566";
  };

  nativeBuildInputs = [
    pkg-config
    zig_0_15
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
    kdePackages.wayland

    egl-x11
    egl-wayland
    libGL
    libGLX
    libGLU
    glew
    glfw
    glm
    wayland
    wayland-protocols
    wayland-scanner

    kdePackages.qtbase
  ];

 #dontWrapQtApps = true;

  buildPhase = ''
    runHook preBuild

    zig build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/man/man6
    cp zig-out/bin/zowon $out/bin/zowon
    cp docs/zowon.6 $out/man/man6/zowon.6

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/imal/zowon";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zowon";
  };
}
