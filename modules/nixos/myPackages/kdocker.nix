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
  ninja,

  kdePackages,

}:

stdenv.mkDerivation rec {
  pname = "KDocker";
  version = "2024-12-07";

  src = fetchFromGitHub {
    owner = "user-none";
    repo = "KDocker";
    rev = "fafae0c3dc6a19a5fc8b4409f6c5789b2306b895";
    hash = "sha256-C5L7B7TzduMVA07bMHp8GMn0ZugCoNFhcgOOko5Ry7c=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
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

    kdePackages.qtbase
  ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp KDocker $out/bin/KDocker
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/user-none/KDocker";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "KDocker";
  };
}
