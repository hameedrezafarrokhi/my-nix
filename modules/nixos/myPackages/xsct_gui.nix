{ lib
, stdenv
, fetchFromGitHub
, python3
, glib
, gobject-introspection
, gdk-pixbuf
, gdk-pixbuf-xlib
, qt6
, xsct
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pycairo
    setuptools
    pyqt6
    devtools
    pysvg-py3
    svg-py
    pillow
    requests
    xlib
    psutil
    ewmh
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "wachin";
    repo = "xsct_gui";
    rev = "main";
    hash = "sha256-R39bXtqv6/m85ugUqHWEemU1hALSqXQ9djPSGpZMAz4=";
  };

  ename = "xsct_gui";

in

stdenv.mkDerivation rec {
  pname = "xsct_gui-py";
  version = "2026-05-01";

  nativeBuildInputs = [
    gobject-introspection
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    pythonEnv
    glib
    gdk-pixbuf-xlib
    gdk-pixbuf
    qt6.qttools
    qt6.qtsvg
    xsct
  ];

  propagatedBuildInputs = buildInputs;

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

    SCRIPT_DIR="$HOME/.local/share/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/xsct_gui.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then

      mkdir -p "$SCRIPT_DIR/xsct_gui"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"

      chmod -R u+rw "$SCRIPT_DIR"
      find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
      find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
      find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;

    fi

    exec ${pname} "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/wachin/xsct_gui";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xsct_gui";
  };
}
