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
  cxxopts,
  jsoncpp,
  pkl,
  doxygen,
  git,

}:

stdenv.mkDerivation rec {
  pname = "yggdrasilwm";
  version = "2024-03-21";

  src = fetchFromGitHub {
    owner = "corecaps";
    repo = "YggdrasilWM";
   #rev = "main";
    rev = "4cffe71162750658cb5be4b0a00cee034341ee3e";
    sha256 = "1bs07ampf047zpcg53irj4xc3c2yy2yz581cdnsl44mj7dmmwzdc";
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
    cxxopts
    jsoncpp
    pkl
    doxygen
    git
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    mkdir build
    cd build
    cmake ..
    make

    runHook postBuild
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp yggdrasilwm $out/bin/yggdrasilwm
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/corecaps/YggdrasilWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "yggdrasilwm";
  };
}
