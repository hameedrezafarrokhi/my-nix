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
  pname = "mxswm";
  version = "2022-12-23";

  src = fetchFromGitHub {
    owner = "tleino";
    repo = "mxswm";
   #rev = "main";
    rev = "d91f7b8904e6caac8067dd9667f8e207c46277a1";
    sha256 = "11nw4ba1363q1vk6zaphfdag8hqlqfihsdajg4pk4vabl2jz6m24";
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

    mkdir -p $out/bin $out/share/man/man1
    cp mxswm $out/bin/mxswm
    cp mxswmctl/mxswmctl $out/bin/mxswmctl
    cp mxswm.1 $out/share/man/man1/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/tleino/mxswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mxswm";
  };
}
