{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "meowwm";
  version = "2019-01-01";

  src = fetchFromGitHub {
    owner = "stevommmm";
    repo = "meow";
    rev = "master";
    hash = "sha256-Ok+Hb2ZaH7DzzOdh0cUjD4m+qSjwArT2ngCewyg95PI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [ "BINARY=meow" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 meow $out/bin/meowwm
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/stevommmm/meow";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "meowwm";
  };
}
