{ lib
, stdenv
, fetchFromGitHub
, python3
}:

let

  scriptRepo = fetchFromGitHub {
    owner = "kying18";
    repo = "minesweeper";
    rev = "fdcf5b5bf003982cd0772669f3f3deae914ed018";
    sha256 = "0ngwgp24y5594n016r6dmwp0shhbvf7xcmig3ghxrmddvd940zf6";
  };

  ename = "minesweeper-py";

in

stdenv.mkDerivation rec {
  pname = "minesweeper-py";
  version = "2022-01-27";

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/minesweeper.py"

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
    homepage = "https://github.com/kying18/minesweeper";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "minesweeper-py";
  };
}
