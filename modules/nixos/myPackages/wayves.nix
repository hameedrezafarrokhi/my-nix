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
, bc
, cava
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    requests
    xlib
    psutil
    pygobject3
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "jvc84";
    repo = "wayves";
    rev = "c5efdd5b736dceee19582d5fa98027f4c3f66637";
    sha256 = "11jy5ghcx3wj6i07vral6dsc1rxn6pbaw27w1zh66g54g2kdzv34";
  };

  ename = "wayves";

in

stdenv.mkDerivation rec {
  pname = "wayves-py";
  version = "2026-01-23";

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
    bc
    cava
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
    MAIN_SCRIPT="$SCRIPT_DIR/wayves.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    mkdir -p $HOME/.config/cava
    cp -n ${scriptRepo}/assets/cava/cava_option_config $HOME/.config/cava/cava_option_config

    chmod -R u+rw "$SCRIPT_DIR"
    chmod -R u+rw "$HOME/.config/cava/cava_option_config"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;
    chmod +x "$SCRIPT_DIR/scripts/play_cava.sh"

    exec ${pname} "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/jvc84/wayves";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wayves";
  };
}
