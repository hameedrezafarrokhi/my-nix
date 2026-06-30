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
  cmake,

  dbus,

}:

stdenv.mkDerivation rec {
  pname = "GooeyDE";
  version = "2025-12-07";

  src = fetchFromGitHub {
    owner = "BinaryInkTN";
    repo = "GooeyDE";
   #rev = "main";
    rev = "ae9a37aab253f73a771142a05336c448752365f9";
    sha256 = "0ighbznpvyki679lrnr4af2az18ghrjkgkcvxdrj4q4lvfdnihdx";
  };

  nativeBuildInputs = [
    pkg-config
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

    dbus
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  prePatch = ''
    rm -f CMakeCache.txt
  '';

  buildPhase = ''
    runHook preBuild

    cmake -S . -B build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp GooeyDE $out/bin/GooeyDE

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/BinaryInkTN/GooeyDE";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "GooeyDE";
  };
}
