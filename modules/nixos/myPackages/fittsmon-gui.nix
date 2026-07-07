{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, gtk3
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
    requests
    xlib
    psutil
    pygame
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "musqz";
    repo = "fittsmon-gui";
    rev = "bd5fb27ad9c72b53c0045d485f773341369de294";
    sha256 = "09ikl9haaqqvg4w8md4qww3q3qsgnipzd6zrcyyrqpbwvhf10kzn";
  };

  ename = "fittsmon-gui";

in

stdenv.mkDerivation rec {
  pname = "fittsmon-gui-py";
  version = "2026-06-22";

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
    gtk3
  ];

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/share/man/man1
    cp ${scriptRepo}/fittsmon-gui.1 $out/share/man/man1/fittsmon-gui.1
    chmod -R u+rw $out/share/man/man1/

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
    MAIN_SCRIPT="$SCRIPT_DIR/fittsmon-gui.py"

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
    Comment=
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/musqz/fittsmon-gui";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fittsmon-gui";
  };
}
