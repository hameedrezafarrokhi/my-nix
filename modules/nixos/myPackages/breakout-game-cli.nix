{
  lib,
  fetchFromGitHub,
  pkg-config,
  go,
  buildGoModule,
  writeText,
  conf ? null,
}:

buildGoModule rec {
  pname = "breakout-game-cli";
  version = "2025-09-19";

  src = fetchFromGitHub {
    owner = "omar0ali";
    repo = "breakout-game-cli";
    rev = "8660f17dedc83549cd38938bceb91814c6ea9976";
    sha256 = "02y6k3b6l2lbsgnwcmxz1gyn73qs26l82ah0ksh4k5a64lr1qq2j";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.toml" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.toml";

  nativeBuildInputs = [ pkg-config ];

  vendorHash = "sha256-ze6+dJp/HMGZwhZmZMadB6ZgcJLgveb+n54NeXii3kI=";

  postInstall = ''
    mkdir -p $out/share/breakout-game-cli
    cp $out/bin/breakout-game-cli $out/share/breakout-game-cli/breakout-game-cli
    cp config.toml $out/share/breakout-game-cli/config.toml
    rm -f $out/bin/breakout-game-cli

    cat > $out/bin/breakout-game-cli << 'EOF'
    #!/usr/bin/env bash

    CURRENT_PATH="$(pwd)"
    #STORE_PATH="$(dirname "$0")"
    STORE_PATH="/run/current-system/sw/share/breakout-game-cli"

    cd "$STORE_PATH"

    exec ./breakout-game-cli "$@"

    cd "$CURRENT_PATH"

    EOF

    chmod +x $out/bin/breakout-game-cli
  '';

  meta = with lib; {
    homepage = "https://github.com/omar0ali/breakout-game-cli";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "breakout-game-cli";
  };
}
