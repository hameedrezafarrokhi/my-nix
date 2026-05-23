{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libxtst,
  libXinerama,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  fontconfig,
  freetype,
  xorgproto,
  go-md2man,
  slop,
  xmenu,
  pkg-config,
  writeScript,
  writeText,
  conf ? null,
  rules ? null,

  moonwm-helper ? null,
  moonwm-menu ? null,
  moonwm-utils ? null,
  moonwm-status ? null,
  swallow ? null,
}:

stdenv.mkDerivation rec {
  pname = "moonwm";
  version = "2022-01-01";

  src = fetchFromGitHub {
    owner = "jzbor";
    repo = "moonwm";
    rev = "master";
    hash = "sha256-rhHtVct17GdTpWfHuPhd4adgti+ebiBsb8zMLaUp/EM=";
  };

  nativeBuildInputs = [ pkg-config go-md2man ];

  buildInputs = [
    libX11
    libXext
    libXrandr
    libxtst
    libXinerama
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    fontconfig
    freetype
    xorgproto
    slop
    xmenu
    moonwm-helper
    moonwm-menu
    moonwm-utils
    moonwm-status
    swallow
  ];

  propagatedBuildInputs = [
    slop
    xmenu
    moonwm-helper
    moonwm-menu
    moonwm-utils
    moonwm-status
    swallow
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
      rulesFile =
        if lib.isDerivation rules || builtins.isPath rules then rules else writeText "rules.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.def.h"
    + " \n " +
    lib.optionalString (rules != null) "cp ${rulesFile} src/rules.def.h"
    ;

  makeFlags = [
    "PREFIX=$(out)"
    "MANPREFIX=$(out)/share/man"
    "DOCPREFIX=$(out)/share/doc"
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error"
    ];
  };

  installPhase = ''
    runHook preInstall

    make install PREFIX=$out MANPREFIX=$out/share/man DOCPREFIX=$out/share/doc

    #if [ -d scripts ] && [ "$(ls -A scripts)" ]; then
    #  make install-scripts PREFIX=$out
    #fi

    make install-docs PREFIX=$out MANPREFIX=$out/share/man DOCPREFIX=$out/share/doc

    runHook postInstall
  '';

 ## Create a wrapper script to ensure runtime dependencies are in PATH
 #postInstall = ''
 #  # Wrap moonwm-helper and other scripts to include runtime deps in PATH
 #  for script in $out/bin/moonwm-helper $out/bin/moonwm-menu $out/bin/moonwm-status $out/bin/moonwm-utils $out/bin/swallow; do
 #    if [ -f "$script" ]; then
 #      wrapProgram "$script" --prefix PATH : ${lib.makeBinPath [ slop xmenu ]}
 #    fi
 #  done
 #'';

  preBuild = ''
    if [ ! -f src/config.h ] && [ -f src/config.def.h ]; then
      cp src/config.def.h src/config.h
    fi
    if [ ! -f src/rules.h ] && [ -f src/rules.def.h ]; then
      cp src/rules.def.h src/rules.h
    fi
  '';

  preConfigure = ''
    make clean || true
  '';

  meta = with lib; {
    homepage = "https://github.com/jzbor/moonwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "moonwm";
  };
}
