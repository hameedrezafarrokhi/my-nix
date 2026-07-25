{ lib
, stdenv
, fetchFromGitHub
, python3
, makeWrapper
}:

let

  pythonEnv = python3.withPackages (ps: with ps; [
    datetime
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "ShadowGoblet20354";
    repo = "dunst-notification-history";
    rev = "b08603c4304bde242a2228d8f12a799f7db2029c";
    hash = "sha256-nJNfVIOWlPlEqms3wFM1bSZPMFMlM9ag+S86F+zURHU=";
  };

  ename = "dunst-notification-history";

in

stdenv.mkDerivation rec {
  pname = "dunst-notification-history-py";
  version = "2022-07-19";

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ pythonEnv ];

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    # Create python wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/n-hist.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;
    chmod +x "$MAIN_SCRIPT"

    exec ${pname} "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/ShadowGoblet20354/dunst-notification-history";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "dunst-notification-history";
  };
}
