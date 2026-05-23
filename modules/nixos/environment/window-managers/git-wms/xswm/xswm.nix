{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "xswm";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "astier";
    repo = "xswm";
    rev = "master";
    hash = "sha256-3YQAm/zm9F/3F7IaS87RCE6j/PtHtmiK3Sz9+enbBYg=";
  };

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "main.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} main.c";

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/astier/xswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xswm";
  };
}
