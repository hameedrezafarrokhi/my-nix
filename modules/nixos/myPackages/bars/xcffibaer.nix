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
    owner = "whitelynx";
    repo = "xcffibaer";
   #rev = "master";
    rev = "aeec1e76ac39c853d1e478fff189b7e87c8a5c5a";
    hash = "sha256-A3u5PVNCEKhqch2eh5tbm0ftr/LiKMKTbyoDoWlYHXI=";
  };

in

stdenv.mkDerivation rec {
  pname = "xcffibaer-py";
  ename = "xcffibaer";
  version = "2024-05-31";

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
    MAIN_SCRIPT="$SCRIPT_DIR/xcffibaer"

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
    homepage = "https://codeberg.org/whitelynx/xcffibaer";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
