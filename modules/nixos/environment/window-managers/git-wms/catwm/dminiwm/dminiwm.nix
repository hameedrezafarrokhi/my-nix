{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "dminiwm";
  version = "2014-12-25";

  src = fetchFromGitHub {
    owner = "moetunes";
    repo = "dminiwm";
    rev = "master";
    hash = "sha256-WVjqZ9VX+Ig6iENB2HngOElUgJr3NguWOIIMQi7YhYE=";
  };

  buildInputs = [ libX11 libXext ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";

  makeFlags = [
    "CFLAGS=-Wall -Wno-incompatible-pointer-types"
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm 755 dminiwm $out/bin/dminiwm
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/moetunes/dminiwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "dminiwm";
  };
}
