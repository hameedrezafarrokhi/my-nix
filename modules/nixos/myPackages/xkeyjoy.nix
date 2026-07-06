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

  autoconf,
  automake,
  libtool,

  libevdev,
  udev,
  libinput,
  libxtst,
}:

stdenv.mkDerivation rec {
  pname = "xkeyjoy";
  version = "2023-07-27";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "colum_paget";
    repo = "xkeyjoy";
    rev = "b0267c92322bc228f43ff6ee379045479d03a578";
    sha256 = "02q56pfryfbw5mgqh6hcj8942kq0044yk7r8f2cdgpzfc084hf5x";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
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

    libevdev
    udev
    libinput
    libxtst
  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];
 #
 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp xkeyjoy $out/bin/xkeyjoy
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/colum_paget/xkeyjoy";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xkeyjoy";
  };
}
