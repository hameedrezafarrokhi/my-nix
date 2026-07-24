{ lib
, stdenv
, fetchFromGitHub
, python3
}:

let

  scriptRepo = fetchFromGitHub {
    owner = "ading2210";
    repo = "snake-cli";
    rev = "d886098f2be5d405e20af3f50d15252dfb49bbb9";
    sha256 = "16y8c9hzhyscw9lxkqb1zn31p4155r8nnjs34q25pnaw9b7q9xv8";
  };

  ename = "snake-cli";

in

stdenv.mkDerivation rec {
  pname = "snake-cli-py";
  version = "2022-05-18";

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/snake.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;
    chmod +x "$MAIN_SCRIPT"

    exec ${python3}/bin/python3 "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/ading2210/snake-cli";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "snake-cli-py";
  };
}
