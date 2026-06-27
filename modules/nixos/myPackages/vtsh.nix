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

  xorgproto,
  libxkbfile,

  pkg-config,

  writeText,
  conf ? null,

  autoconf,
  automake,
  libtool,
}:

stdenv.mkDerivation rec {
  pname = "vtsh";
  version = "2022-08-26";

  src = fetchFromGitHub {
    owner = "tleino";
    repo = "vtsh";
   #rev = "main";
    rev = "4ca55bc0ce7cd1be2c1bffaec1da3bd492887a44";
    sha256 = "0qsy8z3avmsiyhwkncvrpvzlh6a9yd7rgk9nk11llvnmw61rnwsj";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


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

    xorgproto
    libxkbfile
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp vtsh $out/bin/vtsh

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tleino/vtsh";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "vtsh";
  };
}
