{
  lib,
  stdenv,
  fetchzip,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "pong-cli-bin";
  version = "1.0.1";

  src = fetchzip {
    url = "https://github.com/Noah2610/pong-cli/releases/download/v${version}/pong-cli-linux-${version}.zip";
    hash = "sha256-qSy6jirTj1nQC7mC2oM2esNiKU+MWK+3ZtXMWsxQqRs=";
    stripRoot = true;
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "settings.ron" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} settings.ron";

  installPhase = ''
    mkdir -p $out/bin
    cp $src/pong-cli $out/bin/pong-cli
    chmod +x $out/bin/pong-cli
    cp $src/settings.ron $out/bin/settings.ron
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/Noah2610/pong-cli";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "pong-cli";
  };
}
