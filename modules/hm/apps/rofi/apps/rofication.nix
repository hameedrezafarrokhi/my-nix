{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, dbus
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pillow
    requests
    psutil
    pygobject3
    configparser
    jsonpickle
    dbus-python
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "DaveDavenport";
    repo = "Rofication";
    rev = "ef47f397fc9d7c60ff68893130691c5bc352d123";
    sha256 = "04gglrnxpi0y2hbcwykbgn7pp72sf3l3gj8qgpg85lv7crcabra2";
  };

  ename = "rofication";

in

stdenv.mkDerivation rec {
  pname = "rofication-py";
  version = "2023-01-08";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
    dbus
  ];

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
    MAIN_SCRIPT="$SCRIPT_DIR/rofication-daemon.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;

    exec ${pname} "$MAIN_SCRIPT" "$@"

    EOF

    cat > $out/bin/rofication-gui << 'EOF'
    #!/usr/bin/env bash
    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/rofication-gui.py"
    exec ${pname} "$MAIN_SCRIPT" "$@"
    EOF

    cat > $out/bin/rofication-mode << 'EOF'
    #!/usr/bin/env bash
    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/rofication-mode.py"
    exec ${pname} "$MAIN_SCRIPT" "$@"
    EOF

    cat > $out/bin/rofication-statusi3blocks << 'EOF'
    #!/usr/bin/env bash
    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/rofication-statusi3blocks.py"
    exec ${pname} "$MAIN_SCRIPT" "$@"
    EOF

    chmod +x $out/bin/${ename}
    chmod +x $out/bin/rofication-mode
    chmod +x $out/bin/rofication-gui
    chmod +x $out/bin/rofication-statusi3blocks

  '';

  meta = with lib; {
    homepage = "https://github.com/DaveDavenport/Rofication";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofication";
  };
}
