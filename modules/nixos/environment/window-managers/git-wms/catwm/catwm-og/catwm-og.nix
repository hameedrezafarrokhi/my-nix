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
  pname = "catwm-og";
  version = "2024-05-04";

  src = fetchFromGitHub {
    owner = "pyknite";
    repo = "catwm";
    rev = "master";
    hash = "sha256-r0GW1enr9GltpR1wJ7p/o5+8DXqN4nF2+x07xqlQLKw=";
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
    "BINDIR=$(out)/bin"
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm 755 catwm $out/bin/catwm-og
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/pyknite/catwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "catwm-og";
  };
}
