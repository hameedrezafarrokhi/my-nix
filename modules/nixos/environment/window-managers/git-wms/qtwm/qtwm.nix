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

  clang-tools
}:

stdenv.mkDerivation rec {
  pname = "qtwm";
  version = "2015-06-20";

  src = fetchFromGitHub {
    owner = "notaudrey";
    repo = "qtwm";
   #rev = "master";
    rev = "1175cc6b84bd6b0ad524c528e624dc15f56f36e3";
    sha256 = "19zcmjmagza95paplkji65vkklcxfcr21bwl06wc6g6vv9q16zv3";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.h";


  nativeBuildInputs = [
    pkg-config
    clang-tools
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp qtwm $out/bin/qtwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/notaudrey/qtwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "qtwm";
  };
}
