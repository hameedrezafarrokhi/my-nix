{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "eowm";
  version = "2026-01-11";

  src = fetchFromGitHub {
    owner = "atarwn";
    repo = "eowm";
    rev = "main";
    hash = "sha256-Cqt8RGtXkzJuqEGQ61YgdVdmUBTWeHh3TJiPfNJY4ko=";
  };

  buildInputs = [ libX11 libXext libXrandr ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.h";

  NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  installTargets = [ "install" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/atarwn/eowm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "eowm";
  };
}
