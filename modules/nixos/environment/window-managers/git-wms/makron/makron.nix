{
  lib,
  gcc13Stdenv,
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

  libsulfur,
  meson,
  ninja,
  cmake,
  iniparser,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "makron";
  version = "2019-11-14";

  src = fetchFromGitHub {
    owner = "goshhhy";
    repo = "makron";
   #rev = "master";
    rev = "5aa35848cf4323bef8ee5bf48b70abbd5c87a1b7";
    sha256 = "010w522l353m6f3s0wwi2nkxzm24jc59hprdlwjfbi1zgkxr8ynq";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
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

    libsulfur
    iniparser
  ];

  meta = with lib; {
    homepage = "https://github.com/goshhhy/makron";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "makron";
  };
}
