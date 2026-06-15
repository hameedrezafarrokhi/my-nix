{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "echinus";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "echinuspolachok";
    repo = "echinus";
    rev = "master";
    hash = "sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
  };

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    homepage = "https://github.com/echinuspolachok/echinus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "echinus";
  };
}
