{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXcursor,
  libXinerama,
  libXft,
  fontconfig,
  freetype,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "philoswm";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "philopaterwaheed";
    repo = "pwm";
    rev = "main";
    hash = "sha256-QzupIup0iG0TuSHc+WhafHF8+wG1mwOadZSOOIR/g3E=";
  };

  buildInputs = [
    libX11
    libXcursor
    libXinerama
    libXft
    fontconfig
    freetype
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp pwm $out/bin/philoswm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/philopaterwaheed/pwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "philoswm";
  };
}
