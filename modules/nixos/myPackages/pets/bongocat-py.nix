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
, SDL2
, SDL2_image
, SDL2_mixer
, SDL2_ttf

, libxkbcommon
, fuse2
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

    pyside6
    pynput
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "animagr";
    repo = "bongocat";
   #rev = "main";
    rev = "6337ecdc42c8f36262123482a277fa783899b86f";
    sha256 = "0ksklannyzag0jvpfcpa6vi4y0bkc52v1x228sn2aw3j98fbsqfb";
  };

  ename = "bongocat-py";

in

stdenv.mkDerivation rec {
  pname = "bongocat-py-py";
  version = "2026-05-31";

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
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf

    libxkbcommon
    fuse2
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

    SCRIPT_DIR="$HOME/.local/share/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/bongo_cat/main.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;

    cd $SCRIPT_DIR
    exec ${pname} -m bongo_cat "$@"

    EOF

    chmod +x $out/bin/${ename}

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${ename}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=${ename}
    Comment=BongoCat Keyboard (python)
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/animagr/bongocat";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bongocat-py";
  };
}
