{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXinerama,
  libXft,
  freetype,
  writeText,
  conf ? null,
  keys ? null,
}:

stdenv.mkDerivation rec {
  pname = "safwm";
  version = "2023-9-13";

  src = fetchFromGitHub {
    owner = "netfri25";
    repo = "safwm";
    rev = "master";
    hash = "sha256-FCvojxGeKrjRj4ZODdqM3MPJtggbfVmGvieMk9d3XcQ=";
  };

  buildInputs = [ libX11 libXext libXinerama libXft freetype ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
      keysFile =
        if lib.isDerivation keys || builtins.isPath keys then keys else writeText "keymaps.h" keys;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h"
    + " \n " +
    lib.optionalString (keys != null) "cp ${keysFile} keymaps.h"
    ;

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/netfri25/safwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "safwm";
  };
}
