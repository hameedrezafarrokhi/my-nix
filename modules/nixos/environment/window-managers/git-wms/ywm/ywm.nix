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

  autoconf,
  automake,
  libtool,
  m4,

}:

gcc13Stdenv.mkDerivation rec {
  pname = "ywm";
  version = "2024-05-03";

  src = fetchFromGitHub {
    owner = "tcarrill";
    repo = "ywm-xlib";
   #rev = "master";
    rev = "dd8a121b5df856b5d33bb5aacde984a5d682cf7a";
    sha256 = "0cr25jl6a0gkr1iwrw9dx0l88a7jddwjshz1322wrsdrzl1lxlq1";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    m4
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
  ];

  makeFlags = [
    "CC=${gcc13Stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
    "DESTDIR=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    autoreconf --install
    ./configure
    make
    #make install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ywm $out/bin/ywm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tcarrill/ywm-xlib";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ywm";
  };
}
