{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gtk3
, gtk-layer-shell
, gobject-introspection
, libX11
, libXext
, libXft
, libxcb
, libxcb-cursor
, libxcb-image
, libxcb-keysyms
, libxcb-render-util
, libxcb-util
, libxcb-wm
, fontconfig
, pulseaudio
, cairo
, xdpyinfo
, xset
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    evdev
    pyudev
    pycairo
    pillow
    requests
    xlib
    psutil
    ewmh
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "caffienerd";
    repo = "timebomb";
    rev = "main";
    hash = "sha256-j+wqV6X42vK4J4sRNFgFsmW9VOVdYIkYeN5j/UpZ1/Y=";
  };

  ename = "timebomb";

in

stdenv.mkDerivation rec {
  pname = "timebomb-py";
  version = "2026-03-01";

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
    gtk-layer-shell
    fontconfig
    pulseaudio
    libX11
    libXext
    libXft
    cairo
    xdpyinfo
    xset
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
    MAIN_SCRIPT="$SCRIPT_DIR/Linux/python/timebomb.py"

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
    Comment=Time Widget
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/caffienerd/timebomb";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "timebomb";
  };
}
