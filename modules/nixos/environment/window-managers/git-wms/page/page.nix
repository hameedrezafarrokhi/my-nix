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

  autoconf,
  automake,
  libtool,
  breezy,
 #cmake,
  m4,
  bison,
  doxygen,
  flex,

}:

stdenv.mkDerivation rec {
  pname = "page";
  version = "2022-07-13";

  src = fetchFromGitHub {
    owner = "gschwind";
    repo = "page";
   #rev = "master";
    rev = "c6c82affb08090b85668ac6b9882d4e3eb5ccf44";
    sha256 = "0yj5i5xpwcc25iva5rkb0g0yk7g1n5snp0qlia05nwml4byr44lr";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    breezy
   #cmake
    m4
    bison
    doxygen
    flex
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

    autoconf
    automake
    libtool
    breezy
   #cmake
    m4
    bison
    doxygen
    flex
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  preBuild = ''
    aclocal -I m4
    autoconf
    #autoreconf -vfi --make
    automake --add-missing --copy --foreign
  '';

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
 #
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/gschwind/page";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "page";
  };
}
