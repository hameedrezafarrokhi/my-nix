{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "suswm";
  version = "2026-05-18";

  src = fetchFromGitHub {
    owner = "ideiab836";
    repo = "swm";
    rev = "main";
    hash = "sha256-RLlTeBKyHVtIb4GjZaAXmy6Ov2SLLVnn5y9OTWdB4GY=";
  };

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "swm.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} swm.h";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    make install DESTDIR=$out
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/ideiab836/swm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "suswm";
  };
}
