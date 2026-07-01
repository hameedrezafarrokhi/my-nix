{ lib
, stdenv
, fetchFromGitea
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
}:

let

  pythonEnv = python3.withPackages (ps: with ps; [
    appdirs
    cairocffi
    cffi
    click
    cython
    i3ipc
    netifaces
    packaging
    pycparser
    pyparsing
    pystatgrab
    python-dateutil
    six
    xpybutil
    xcffib
    aenum
    setuptools
  ]);

  scriptRepo = fetchFromGitea {
    domain = "codeberg.org";
    owner = "tsugibayashi";
    repo = "pyoutput_status";
   #rev = "master";
    rev = "7e6f90f919fd7813ac6f84ffd8a8cae23e62cfe3";
    hash = "sha256-ue3gktlrfKsZr4fvF0AazjCOehhwB//KzHSuHgmichE=";
  };

in

stdenv.mkDerivation rec {
  pname = "pyoutput_status-py";
  ename = "pyoutput_status";
  version = "2026-04-11";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
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
    MAIN_SCRIPT="$SCRIPT_DIR/pyoutput_status/pyoutput_status.py"

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
    Comment=wm tiler
    Exec=$out/bin/${ename}
    EOF
  '';

  meta = with lib; {
    description = "wm tiler";
    homepage = "https://codeberg.org/tsugibayashi/pyoutput_status";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
