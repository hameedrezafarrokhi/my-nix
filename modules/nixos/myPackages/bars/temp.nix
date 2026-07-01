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

  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "sowm";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "sowm";
   #rev = "main";
    rev = "AAA4d22bf6cf4e1abd520921eacce1fe38277741";
    sha256 = "AAAfcxhz8m399skm7jk0348561722kgwgpqs5gk351i6sb0phglf";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";


  nativeBuildInputs = [
    pkg-config
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
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild



    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp sowm $out/bin/sowm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/dylanaraps/sowm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sowm";
  };
}
