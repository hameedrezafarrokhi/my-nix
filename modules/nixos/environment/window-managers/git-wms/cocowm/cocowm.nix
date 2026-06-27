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
  pname = "cocowm";
  version = "2023-02-01";

  src = fetchFromGitHub {
    owner = "tleino";
    repo = "cocowm";
   #rev = "main";
    rev = "9e2d79c2187865143d122e5dc92e7c3739047e1e";
    sha256 = "1hjlbn6rixx09173ji6zd1zan1qssl4qk2lhpy9vnfc779pzahg0";
  };

 #postPatch =
 #  let
 #    configFile =
 #      if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
 #  in
 #  lib.optionalString (conf != null) "cp ${configFile} config.def.h";


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
    cp cocowm $out/bin/cocowm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tleino/cocowm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "cocowm";
  };
}
