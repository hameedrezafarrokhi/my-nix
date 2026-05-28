{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXrandr,
  libxtst,
 #xmodmap,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  python3,
  python3Packages,
  makeWrapper,
  gobject-introspection,
  glib,
  wrapGAppsHook3,
  writeText,
  conf ? null,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    configparser
    xlib
    setuptools
    ewmh
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "h-ohsaki";
    repo = "xpywm";
    rev = "master";
    hash = "sha256-wQ7wDeww12Oow+JoC8iOGMKxcUo8Osp13tTEYZEB2C8=";
  };

  xpymon = fetchFromGitHub {
    owner = "h-ohsaki";
    repo = "xpymon";
    rev = "master";
    hash = "sha256-JKwDtY2Ibdww9qss4q8vHJXO9aGKN7D8PHElvmQQp2k=";
  };

  xpylog = fetchFromGitHub {
    owner = "h-ohsaki";
    repo = "xpylog";
    rev = "master";
    hash = "sha256-R8Pu8ko4LOKWHhObRkeUI5ULIvrPOzCN3pKAS1gDRiU=";
  };

  ename = "xpywm";

in

stdenv.mkDerivation rec {
  pname = "xpywm-py";
  version = "2021-01-01";

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "xpywm" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} xpywm";

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
    MAIN_SCRIPT="$SCRIPT_DIR/xpywm"

    MON_DIR="$HOME/.config/xpymon"
    MON_SCRIPT="$MON_DIR/xpymon"

    LOG_DIR="$HOME/.config/xpylog"
    LOG_SCRIPT="$LOG_DIR/xpylog"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp ${scriptRepo}/xpywm "$SCRIPT_DIR/"
    fi
    chmod -R u+rw "$SCRIPT_DIR"
    chmod 644 $MAIN_SCRIPT

    if [ ! -f "$MON_SCRIPT" ]; then
      mkdir -p "$MON_DIR"
      cp -r ${xpymon}/xpymon "$MON_DIR/"
    fi
    chmod -R u+rw "$MON_DIR"
    chmod 644 $MON_SCRIPT

    if [ ! -f "$LOG_SCRIPT" ]; then
      mkdir -p "$LOG_DIR"
      cp -r ${xpylog}/xpylog "$LOG_DIR/"
    fi
    chmod -R u+rw "$LOG_DIR"
    chmod 644 $LOG_SCRIPT

    exec ${pname} "$MAIN_SCRIPT" &
    exec ${pname} "$MON_SCRIPT" &
    exec ${pname} "$LOG_SCRIPT"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/h-ohsaki/xpywm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xpywm-py";
  };
}
