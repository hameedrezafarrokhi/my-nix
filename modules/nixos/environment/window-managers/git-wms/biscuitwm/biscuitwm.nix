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
   #ewmh # WARNING Need After Internet
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "csiew";
    repo = "BiscuitWM";
    rev = "master";
    hash = "sha256-T2/pG5H7JTvT2eDHMvRZJbOEdaQATAbN8lDP4e9ExaE=";
  };

  ename = "biscuitwm";

in

stdenv.mkDerivation rec {
  pname = "biscuitwm-py";
  version = "2021-01-01";

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "biscuitwm.json" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} biscuitwm.json";

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

    mkdir -p $out/etc
    if [ -f "biscuitwm.json" ]; then
      cp biscuitwm.json $out/etc/
    else
      cp ${scriptRepo}/assets/biscuitwm.json $out/etc/
    fi

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
    MAIN_SCRIPT="$SCRIPT_DIR/src/main.py"

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
    homepage = "https://github.com/csiew/BiscuitWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "biscuitwm-py";
  };
}
