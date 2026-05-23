{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXinerama,
  libXrandr,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "pwm";
  version = "2026-04-01";

  src = fetchFromGitHub {
    owner = "MateuszDubaj";
    repo = "PWM";
    rev = "main";
    hash = "sha256-CQuyDg6sBeJU4rTJc0BCQsA0AUb/T4dTwX939unx5LM=";
  };

  sourceRoot = "source/src";

  nativeBuildInputs = [ ];

  buildInputs = [ libX11 libXrandr ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [
    "PREFIX=$(out)"
    "CC=cc"
  ];

  installPhase = ''
    runHook preInstall

    make install PREFIX=$out

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/MateuszDubaj/PWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "pwm";
  };
}
