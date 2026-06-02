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
   #pyqt5
   #pyqt5-sip
    pyqt5-multimedia
    urllib3
    certifi
    charset-normalizer
    idna
    requests
    xlib
    psutil
    pygame
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "SergiusYT";
    repo = "Tux_Assistant";
    rev = "main";
    hash = "sha256-3ZhbFgnLKppWib3sfpC0Rt9xnDRz/nvZH8MbPO8QcFs=";
  };

  ename = "Tux_Assistant";

in

stdenv.mkDerivation rec {
  pname = "Tux_Assistant_Py";
  version = "2026-02-01";

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
    Comment=Tux Pet
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/SergiusYT/Tux_Assistant";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "Tux_Assistant";
  };
}
