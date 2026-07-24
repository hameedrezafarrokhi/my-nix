{ lib
, stdenv
, fetchFromGitHub
, python3
}:

let

  scriptRepo = fetchFromGitHub {
    owner = "thesquash101";
    repo = "py-flappy-bird";
    rev = "fecd47d4bd37c8e78c24dcca5afb779a70f86afb";
    sha256 = "091gz7ihhgyn38b1jgz5f4zv96llxk1hy3n98ls2m68w1fwxjdvy";
  };

  ename = "py-flappy-bird";

in

stdenv.mkDerivation rec {
  pname = "py-flappy-bird";
  version = "2026-03-30";

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/py-flappybird.py"

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

    cat > $out/bin/py-flappybird-2player << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/py-flappybird-2player.py"

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

    chmod +x $out/bin/py-flappybird-2player

  '';

  meta = with lib; {
    homepage = "https://github.com/thesquash101/py-flappy-bird";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "py-flappy-bird";
  };
}
