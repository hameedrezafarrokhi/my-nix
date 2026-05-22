{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libX11,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "monsterwm-xcb";
  version = "2016-01-01";

  src = fetchFromGitHub {
    owner = "Cloudef";
    repo = "monsterwm-xcb";
    rev = "master";
    hash = "sha256-FYyIdd0uRQWEXflielISxFJbgsJvvlazg2hTH6vMXn4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";


  preBuild = ''
    cp config.def.h config.h
  '';

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "MANPREFIX=${placeholder "out"}/share/man"
  ];

  installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/Cloudef/monsterwm-xcb";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "monsterwm-xcb";
  };
}
