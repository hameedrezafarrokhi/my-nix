{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, libxcb
, libxcb-cursor
, libxcb-image
, libxcb-keysyms
, libxcb-render-util
, libxcb-util
, libxcb-wm
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pillow
    pyqt6
    requests
    xlib
    psutil
   #ewmh          # WARNING Need After Internet
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "rostikcermak-pixel";
    repo = "Konqi-Pet";
    rev = "main";
    hash = "sha256-G9wUFG7aYV4N3m3qizXrBmuvwOMLOWlrNz50UVF52BM=";
  };

  ename = "Konqi-Pet";

in

stdenv.mkDerivation rec {
  pname = "Konqi-Pet-Py";
  version = "2026-05-01";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
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
    MAIN_SCRIPT="$SCRIPT_DIR/main.py"

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

    chmod +x $out/bin/${ename}

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${ename}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=${ename}
    Comment=A KDE Pet
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/rostikcermak-pixel/Konqi-Pet";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "Konqi-Pet-Py";
  };
}
