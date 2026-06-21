{
  lib,
  gcc13Stdenv,
  gcc13,
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
  conf ? null,
  conf2 ? null,

  dmenu,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "notewm";
  version = "2026-03-27";

  src = fetchFromGitHub {
    owner = "masonarmand";
    repo = "NoteWM";
   #rev = "main";
    rev = "8d17e5c8765f76eb410ca87e599838e29e014a8c";
    sha256 = "0vkjz6xymrmgw8rx9zm6n3vwzi42jyvwqvw3gpfad8r1k5sy2v09";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "notewm.h" conf;
      configFile2 =
        if lib.isDerivation conf2 || builtins.isPath conf2 then conf2 else writeText "main.c" conf2;
    in
    lib.optionalString (conf != null) "cp ${configFile} notewm.h"
    + " \n " +
    lib.optionalString (conf2 != null) "cp ${configFile2} main.c"
    ;


  nativeBuildInputs = [
    pkg-config
    gcc13
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

    dmenu
  ];

  makeFlags = [
    #"CC=${gcc13Stdenv.cc.targetPrefix}cc"
    #"CC=${gcc13}/bin/gcc"
    #"PREFIX=$(out)"
  ];

  buildPhase = ''
    ${gcc13}/bin/gcc -g -std=c89 *.c ./libs/inih/ini.c -I./libs/inih -lX11 -o notewm
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 notewm $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/masonarmand/NoteWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "notewm";
  };
}
