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
  libxkbfile,

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
}:

stdenv.mkDerivation rec {
  pname = "hsdwm";
  version = "2026-06-16";

  src = fetchFromGitHub {
    owner = "hsdcc";
    repo = "hsdwm";
   #rev = "main";
    rev = "043d5d67aa0e778592adee4ad7b720ef742291bc";
    sha256 = "0mkr46bdxf6bsd5m6hr57nb7rm1w3wf5ycq2wxf0hrl4nd6jarlh";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "wm.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} wm.c";

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
    libxkbfile

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

  installPhase = ''
    mkdir -p $out/bin
    cp thing $out/bin/hsdwm
  '';

  meta = with lib; {
    homepage = "https://github.com/hsdcc/hsdwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "hsdwm";
  };
}
