{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, gtk3
, gdk-pixbuf
, gdk-pixbuf-xlib
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pycairo
    setuptools

    pillow
    requests
    xlib
    psutil
    ewmh
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "theKlanc";
    repo = "clearine";
    rev = "master";
    hash = "sha256-Q4G1dG3fH9XSE9D2zxKaRCyFTPAVVbyjSlvZ80Y9GdQ=";
  };

  ename = "clearine";

in

stdenv.mkDerivation rec {
  pname = "clearine-py";
  version = "2019-01-01";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
    gtk3
    gdk-pixbuf-xlib
    gdk-pixbuf
  ];

  propagatedBuildInputs = buildInputs;

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    # Create python wrapper
    mkdir -p $out/bin
    mkdir -p $out/share/clearine
    cp ${scriptRepo}/src/data/clearine.conf $out/share/clearine/
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.local/share/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/src/clearine.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then

      mkdir -p "$SCRIPT_DIR/src/Clearine"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
      cp -r ${scriptRepo}/src/helper.py "$SCRIPT_DIR/src/Clearine/"

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
    homepage = "https://github.com/theKlanc/clearine";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "clearine";
  };
}
