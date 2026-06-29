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

  fox,
}:

stdenv.mkDerivation rec {
  pname = "FoxWM";
  version = "2022-10-02";

  src = fetchFromGitHub {
    owner = "PGSafarik";
    repo = "FoxWM";
   #rev = "master";
    rev = "f12535b31a377be2309dc3c875523e5c6f437417";
    sha256 = "1klywwcbn1v7ifkzck2zdivd62a53z4gzc5i8w4il09h3i7xngii";
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

    fox
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    mkdir build
    cd build
    cmake ..
    make
    make install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    #mkdir -p $out/bin
    #cp FoxWM $out/bin/FoxWM

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/PGSafarik/FoxWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "FoxWM";
  };
}
