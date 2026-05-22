{
  lib,
  stdenv,
  fetchFromGitHub,
 #fetchFromSourceHut,
  libX11,
  gcc,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "moody";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "leanghok120";
    repo = "moody";
    rev = "master";
    hash = "sha256-eEF20H5nFyBSW6jrF2p2eohxNyKliqj+f1mcALMtM24=";
  };

 #src = fetchFromSourceHut {    # Moved to SourceHut Change After Internet
 #  owner = "~leanghok";
 #  repo = "moody";
 #  rev = "master";
 #  hash = "sha256-AAAAAAK86pFkAAAAAAxgyoEwAAABaZQmFOkUFAAAAAA=";
 #};

  nativeBuildInputs = [ gcc ];

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  buildPhase = ''
    gcc -o moody moody.c -lX11
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp moody $out/bin/
  '';

  meta = with lib; {
   #homepage = "https://github.com/leanghok120/moody";
    homepage = "https://git.sr.ht/~leanghok/moody";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "moody";
  };
}
