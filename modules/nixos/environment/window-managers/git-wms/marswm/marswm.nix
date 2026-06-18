{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxft,
  libxinerama,
  libxrandr,
  pkg-config,
  rustPlatform,
  glib,


  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

rustPlatform.buildRustPackage rec {
  pname = "marswm";
  version = "2026-02-24";

  src = fetchFromGitHub {
    owner = "jzbor";
    repo = "marswm";
   #rev = "master";
    rev = "af71a970f216b60b2074df405f06372a0e1bfd2b";
    sha256 = "0cgy6kzc10kfrmradm9fsc70v4s4b3b852c3nf6dhksb1lr3dh3n";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libx11
    libxft
    libxinerama
    libxrandr
    glib
  ];

 #inherit patches;
 #
 #postPatch =
 #  let
 #    configFile =
 #      if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
 #  in
 #  lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  meta = with lib; {
    homepage = "https://github.com/jzbor/marswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "marswm";
  };
}
