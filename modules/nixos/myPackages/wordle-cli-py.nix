{ lib
, stdenv
, fetchFromGitHub
, python3,
  writeText,
  conf ? null,
}:

let

  scriptRepo = fetchFromGitHub {
    owner = "hannahherbig";
    repo = "wordle-cli";
    rev = "f61f15fd175cadfb3fc97c349393c817d51b1834";
    hash = "sha256-6XLu5g8Z76uGv03cDwOVknk5iS2bM05ojvzJSZU4UQo=";
  };

  ename = "wordle-cli-py";

in

stdenv.mkDerivation rec {
  pname = "wordle-cli-py";
  version = "2022-01-11";

  buildInputs = [
    python3
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.ini" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.ini";

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    # Create python wrapper
    mkdir -p $out/bin

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/play.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;
    chmod +x "$MAIN_SCRIPT"

    exec "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${ename}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=${ename}
    Comment=Cats On Screen
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/hannahherbig/wordle-cli";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wordle-cli-py";
  };
}
