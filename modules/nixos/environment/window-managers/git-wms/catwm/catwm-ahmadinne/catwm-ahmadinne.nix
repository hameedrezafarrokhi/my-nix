{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXinerama,
  libXft,
  dzen2,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "catwm-ahmadinne";
  version = "2025-09-019";

  src = fetchFromGitHub {
    owner = "ahmadinne";
    repo = "catwm";
    rev = "master";
    hash = "sha256-uW/bKcmWyxJJdxpFezz0ge2oNSpSF8ZG3H0WblLEo6o=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 libXext libXft libXinerama dzen2 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [ "PREFIX=$(out)" ];

  preBuild = ''
    cp config.def.h config.h
    substitute config.mk config.mk \
      --replace "/usr/local" "${placeholder "out"}" \
      --replace "-lX11" "-lX11 -lXinerama -lXft"
  '';

  installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/ahmadinne/catwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "catwm-ahmadinne";
  };
}
