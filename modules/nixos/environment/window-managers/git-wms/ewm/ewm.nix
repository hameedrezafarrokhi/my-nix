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
}:

stdenv.mkDerivation rec {
  pname = "ewm";
  version = "2024-1-27";

  src = fetchFromGitHub {
    owner = "pwnwriter";
    repo = "ewm";
    rev = "main";
    hash = "sha256-Q+sEv8cYrRxqwQq27grhiluw9g+PKiTR0CIV+sjoq20=";
  };

  buildInputs = [ libX11 libXext libXinerama libXft freetype ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.def.h";

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/pwnwriter/ewm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ewm";
  };
}
