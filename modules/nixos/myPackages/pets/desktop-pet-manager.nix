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
, dbus
, xprop
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
    pyqt6
    pyside6
    pynput
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "M1Nassiri";
    repo = "Desktop_pet_manager";
   #rev = "main";
    rev = "bdae77a764d285af69aa2301dd2a35dc909d4b17";
    sha256 = "0dkk7dh2891zfdwh6jq26vs5z550qqx77h7f1xc38wzhr9apvb62";
  };

  ename = "desktop_pet_manager";

in

stdenv.mkDerivation rec {
  pname = "desktop_pet_manager-py";
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
    dbus
    xprop
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
    MAIN_SCRIPT="$SCRIPT_DIR/pet_manager.py"

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
    Name=${ename}
    Comment=Animated character overlay for the desktop
    Icon=face-smile
    Type=Application
    Categories=Utility;
    StartupNotify=false
    NoDisplay=true
    Version=1.0
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/M1Nassiri/Desktop_pet_manager";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "desktop_pet_manager";
  };
}
