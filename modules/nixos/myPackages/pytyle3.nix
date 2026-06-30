{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
}:

let

  pythonEnv = python3.withPackages (ps: with ps; [
    xpybutil
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "pytyle3";
   #rev = "master";
    rev = "8a1ca4189659a4fd2250eb8c2166b630210e8eae";
    hash = "sha256-WNfhK4OjAx5km5AOk3V3cmwe8GvIGjOShTsJ/gWSoW0=";
  };

in

stdenv.mkDerivation rec {
  pname = "pytyle3-py";
  ename = "pytyle3";
  version = "2025-10-05";

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
    MAIN_SCRIPT="$SCRIPT_DIR/pytyle3"

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
    homepage = "https://github.com/BurntSushi/pytyle3";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
