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

  libconfig,

  writeText,
  conf ? null,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "fleon";
  version = "2023-01-31";

  src = fetchFromGitHub {
    owner = "kamui-fin";
    repo = "fleon";
   #rev = "main";
    rev = "e42573a09f855420542d57679328d204106de491";
    sha256 = "1mnm5x0fs4ddjksj25srmyiwmxxypm7byziamck66s968n47xjw1";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "fleon.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} fleon.h";


  nativeBuildInputs = [
    pkg-config
    libconfig
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
    libconfig
  ];

  makeFlags = [
    "CC=${gcc13Stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp fleon $out/bin/fleon

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/kamui-fin/fleon";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fleon";
  };
}
