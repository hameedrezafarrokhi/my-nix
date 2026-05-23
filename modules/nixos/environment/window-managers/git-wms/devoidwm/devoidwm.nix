{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  xorgproto,
  gcc,
  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "devoidwm";
  version = "2021-01-01";

 #src = fetchFromGitHub {
 #  owner = "murtaza-u";
 #  repo = "devoidwm";
 #  rev = "main";
 #  hash = "sha256-RJMJ4UgFNh0h+7P2gbBS+U+ZsUOiozHGB1f0N/XQxmw=";
 #};

  src = ./devoidwm-patched;

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 xorgproto ];

  inherit patches;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [ "PREFIX=$(out)" ];

  buildPhase = ''
    runHook preBuild

    gcc config.c src/*.c -o devoid -lX11 -std=c99 -Wall -Wextra -pedantic -Os

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d $out/bin
    install -m 755 devoid $out/bin/devoidwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/murtaza-u/devoidwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "devoidwm";
  };
}
