{ lib
, stdenv
, fetchFromGitHub
}:

let

  scriptRepo = fetchFromGitHub {
    owner = "siduck";
    repo = "bubbly";
    rev = "3254e943831e2fb25bbdcaffc404ed36cf232c00";
    hash = "sha256-DvJ7h7hmIXuf+0TPzYZnamcSugIDhCGHpcW/D1zgEGQ=";
  };

in

stdenv.mkDerivation rec {
  pname = "bubbly";
  version = "2025-01-03";

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''

    mkdir -p $out/bin

    # Create Launcher
    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.local/share/${pname}"
    MAIN_SCRIPT="$SCRIPT_DIR/start.sh"
    CONF_DIR="$HOME/.config/bubbly"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
      chmod -R u+rw "$SCRIPT_DIR"
      find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
      find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
      find "$SCRIPT_DIR" -name "*.sh" -exec chmod 644 {} \;
      chmod +x "$MAIN_SCRIPT"
      chmod +x "$SCRIPT_DIR/selector/scripts/switchMode.sh"
      chmod +x "$SCRIPT_DIR/keystrokes/scripts/gen_gradient.sh"
      chmod +x "$SCRIPT_DIR/keystrokes/scripts/getkeys.sh"
      chmod +x "$SCRIPT_DIR/bubbles/scripts/bubbles.sh"
      chmod +x "$SCRIPT_DIR/bubbles/scripts/getkeys.sh"
    fi

    if [ ! -d "$CONF_DIR" ]; then
      mkdir -p "$CONF_DIR"
      cp -r ${scriptRepo}/config/* "$CONF_DIR/"
      chmod -R u+rw "$CONF_DIR"
      find "$CONF_DIR" -type f -exec chmod 644 {} \;
    fi

    exec "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${pname}

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=${pname}
    Comment=Chat Bubble For Keys
    Exec=$out/bin/${pname}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/siduck/bubbly";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bubbly";
  };
}
