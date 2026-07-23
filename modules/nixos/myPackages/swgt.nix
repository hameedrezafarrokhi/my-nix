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
  fontconfig,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "swgt";
  version = "2025-08-26";

  src = fetchFromGitHub {
    owner = "Kubandir";
    repo = "swgt";
    rev = "75294618c47bc90e0c31f2598db270033adffae4";
    sha256 = "0w6pfn8naj9hvk2d241svjqgynldagzdljk6nvva19lcsnj4nr2b";
  };

 #src = ./swgt;

  prePatch = ''
    substituteInPlace swgt.c \
      --replace-fail 'attrs.override_redirect = True;' 'attrs.override_redirect = False;'
  '';

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


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
    fontconfig
    freetype
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp swgt $out/bin/swgt

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Kubandir/swgt";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "swgt";
  };
}
