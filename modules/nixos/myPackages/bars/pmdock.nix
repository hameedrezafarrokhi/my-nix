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

  imlib2Full,
  clang-tools,
  clang,
}:

stdenv.mkDerivation rec {
  pname = "pmdock";
  version = "2025-01-17";

  src = fetchFromGitHub {
    owner = "luke8086";
    repo = "pmdock";
   #rev = "main";
    rev = "72e17d2aec1e4549ade3cec611b74904d08c46c0";
    sha256 = "0k5a0dbchrw57cw9yr0qv6dcix8gl1fs77lmkirq7i6wiapz3l4c";
  };

  nativeBuildInputs = [
    pkg-config
    clang-tools
    clang
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

    imlib2Full
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp pmdock $out/bin/pmdock

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/luke8086/pmdock";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "pmdock";
  };
}
