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
, wmctrl
, libappindicator-gtk3
, gtk3
, cairo
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

    pycairo

    pynput
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "bmuhammadam1n";
    repo = "desktop-pets";
   #rev = "main";
    rev = "d15bceaff7d9d9044827cea34c26836a14bf756d";
    sha256 = "0is5qh8zx23jcy6xmgbgsf2zxlw8i5zs15rslgw1jr1fb4crzq6j";
  };

  ename = "desktop-pets";

in

stdenv.mkDerivation rec {
  pname = "desktop-pets-py";
  version = "2026-04-08";

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
    wmctrl
    libappindicator-gtk3
    gtk3
    cairo
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
    MAIN_SCRIPT="$SCRIPT_DIR/desktop-pets.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;

    cd $SCRIPT_DIR
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
    Comment=Desktop Pets
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/bmuhammadam1n/desktop-pets";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "desktop-pets";
  };
}
