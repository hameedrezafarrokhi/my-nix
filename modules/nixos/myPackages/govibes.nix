{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  pkg-config,
  buildGoModule,

  sox_ng,

  writeText,
  conf ? null,
}:

buildGoModule rec {
  pname = "govibes";
  version = "2024-11-22";

  src = fetchFromGitHub {
    owner = "manish-mehra";
    repo = "govibes";
    rev = "e45c11342f57e08dfedf1ec787da59b8e923ff5d";
    sha256 = "0nbirgfy7yaw43j7bralnflfyp92gqglscdba5ynxndgchvazh43";
  };

  vendorHash = "sha256-cVkroKJlU+s9dIRuNSbKAk0evpwYTSoG6ZvtQzdRUaE=";

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "preference.json" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} preference.json";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sox_ng
  ];

  postInstall = ''
    mkdir -p $out/audio $out/share/govibes
    cp -r audio/* $out/audio/
    cp preference.json $out/share/govibes/preference.json

    mkdir -p $out/share/govibes/audio

    cp -f $out/bin/govibes $out/share/govibes/govibes
    cp -r audio/* $out/share/govibes/audio/

    # Create Launcher
    cat > $out/bin/govibes-launch << 'EOF'
    #!/usr/bin/env bash

    cd /run/current-system/sw/share/govibes
    ./govibes

    EOF

    # Create Launcher
    cat > $out/bin/govibes-mutable << 'EOF'
    #!/usr/bin/env bash

    mkdir -p $HOME/.local/share/govibes
    cp -rn ${src}/* $HOME/.local/share/govibes/
    cp -rf /run/current-system/sw/bin/govibes $HOME/.local/share/govibes/govibes

    chmod -R u+rw $HOME/.local/share/govibes

    cd $HOME/.local/share/govibes/
    ./govibes

    EOF

    chmod +x $out/bin/govibes-launch
    chmod +x $out/share/govibes/govibes
    chmod +x $out/bin/govibes-mutable
  '';

  meta = {
    homepage = "https://github.com/manish-mehra/govibes";
    description = "govibes";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
