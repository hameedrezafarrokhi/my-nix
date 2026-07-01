{ lib
, stdenv
, fetchFromGitHub
, python313
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
, writeText
, conf ? null
, libnotify
, dbus
}:

let
  pythonEnv = python313.withPackages (ps: with ps; [
    pillow
    notify-py
    notify2
    notify-events
    pycairo
    pyinotify
    asyncinotify
    sdnotify
    lmnotify
    inotify
    notifications-python-client
    requests
    python-google-weather-api
    xlib
    psutil
    pygame
    pygobject3
    configparser
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "J-CITY";
    repo = "unknowdock";
   #rev = "master";
   #hash = "sha256-7sJKL10NKvCEW/sy5HwoP3KdN+PuwMKFdaR8Z3ddWJ8=";
    rev = "6a305e8dcf255baf51ad30e77e62219dd084c21c";
    sha256 = "1di1vj67jwsh2yy5b5p9x88swh9kywy63mfzgak0hirxnlz3smw1";
  };

  ename = "unknowdock";

in

stdenv.mkDerivation rec {
  pname = "unknowdock-py";
  version = "2020-08-17";

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
    libnotify
    dbus
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
      --prefix PYTHONPATH : "${pythonEnv}/${python313.sitePackages}"

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/unknowdock.py"

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

  '';

  meta = with lib; {
    homepage = "https://github.com/J-CITY/unknowdock";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "unknowdock";
  };
}
