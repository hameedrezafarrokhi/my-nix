{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, libx11
, libxft
, libxrandr
, libxrender
, libxres
, libxcursor
, libxext
, libxi
, libxinerama
, libxmu
, libxpm
, libxmp
, libxt
, libxdamage
, libxdmcp
, libxcomp
, libxcomposite
, libxkbcommon

, libxcb
, libxcb-wm
, libxcb-util
, libxcb-render-util
, libxcb-keysyms
, libxcb-image
, libxcb-errors
, libxcb-cursor

, fontconfig
, freetype

, pkg-config
, qt5
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
   #pyqt5-multimedia
    pyqt5-sip
    pyqt5
   #qt5reactor
    dbus-next
    cssutils
    setproctitle
    pillow
    requests
    xlib
    psutil
    pygame
    pygobject3
    configparser

    pyinstaller
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "ikz87";
    repo = "yawns";
   #rev = "main";
    rev = "109a8645618e97a0106ecb149c2b92a9fe6bd7df";
    sha256 = "0cwrcz52l59a51lsg3zmzs9rl7fiinsm04q16rb20cl4xymjg05g";
  };

  ename = "yawns";

in

stdenv.mkDerivation rec {
  pname = "yawns-py";
  version = "2026-03-02";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    qt5.wrapQtAppsHook
    qt5.qtx11extras
    qt5.qtbase
  ];

  buildInputs = [
    pythonEnv
    glib
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
    qt5.qtx11extras
    qt5.qtbase
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
    MAIN_SCRIPT="$SCRIPT_DIR/app.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR" "$SCRIPT_DIR/assets"
      cp -r ${scriptRepo}/src/* "$SCRIPT_DIR/"
      cp -r ${scriptRepo}/assets/* "$SCRIPT_DIR/assets"
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
    Comment=x11 notification and widgets
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/ikz87/yawns";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "yawns";
  };
}
