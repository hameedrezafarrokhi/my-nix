{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  xorgproto,
  pkg-config,
  libXft,
  freetype,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "chibiwm";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "Mangrogred";
    repo = "chibiwm";
    rev = "main";
    hash = "sha256-/6LNTpOEGM96otUxL1ku6oz7HA33VULHLnMt7+WKZ5A=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXft
    xorgproto
    freetype
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [ "CC=gcc" ];

  installPhase = ''
    mkdir -p $out/bin
    cp chibiwm $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/Mangrogred/chibiwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "chibiwm";
  };
}
