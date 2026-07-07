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

  which,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "matwm2";
  version = "2026-03-28";

  src = fetchFromGitHub {
    owner = "segin";
    repo = "matwm2";
    rev = "a3a5fb2912545d1b7505eb0ac0f3f4a4d45e1435";
    sha256 = "19v419l7yvvg7mhrxjc23xvw1fbc6bs3v19l7smwnz4ig578nkfv";
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
    which
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  preInstall = ''
    substituteInPlace Makefile \
      --replace '/usr/local' '${placeholder "out"}'
  '';

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp matwm2 $out/bin/matwm2
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/segin/matwm2";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "matwm2";
  };
}
