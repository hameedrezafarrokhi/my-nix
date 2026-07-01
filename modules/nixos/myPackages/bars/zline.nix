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

  zig,
  alsa-lib,
  alsa-tools,
}:

stdenv.mkDerivation rec {
  pname = "zline";
  version = "2026-06-21";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "metanoia";
    repo = "zline";
    rev = "a9aeed9c52818d0bafdfcae73e1eb62013de9791";
    hash = "sha256-TT1F3T3DZgkRDilYtLwc0NYn2Y5BK6JTUK7LXmtIOh8=";
  };

  nativeBuildInputs = [
    pkg-config
    zig
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
    alsa-lib
    alsa-tools
  ];

  buildPhase = ''
    runHook preBuild

    zig build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-out/bin/zline $out/bin/zline

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/metanoia/zline";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zline";
  };
}
