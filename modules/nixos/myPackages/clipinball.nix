{ lib
, stdenv
, fetchFromGitHub
, python3
}:

let

  scriptRepo = fetchFromGitHub {
    owner = "rlndr";
    repo = "clipinball";
    rev = "2343e18aeb6fadbaa6b5721d1bf5dd2fab17a090";
    sha256 = "1bsk2sx2c33s599vmwx4f3hmr35ml7k92r4swcbcqrv4hhb1zxdp";
  };

  ename = "clipinball";

in

stdenv.mkDerivation rec {
  pname = "clipinball";
  version = "2026-04-12";

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/pinball.py"

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
    homepage = "https://github.com/rlndr/clipinball";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "clipinball-py";
  };
}
