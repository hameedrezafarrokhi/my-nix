{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, writeText
, conf ? null
}:

let

  configFile = if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.py" conf;

  pythonEnv = python3.withPackages (ps: with ps; [
    pillow
    requests
    psutil
    pygobject3
    configparser
    pycurl
    subprocess-tee
    urllib3
    jsondate
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "clifordjoshy";
    repo = "rofi-ytm";
    rev = "543b58009a73c20a4cf0ac99e49b2b93d010f99f";
    hash = "sha256-8QX+apnu/syXOgnNYPHRFeqgb48KPMhsJ8OUwQ8tVhM=";
  };

  ename = "rofi-ytm";

in

stdenv.mkDerivation rec {
  pname = "rofi-ytm-py";
  version = "2022-01-02";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
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
    MAIN_SCRIPT="$SCRIPT_DIR/rofi-ytm.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/* "$SCRIPT_DIR/"
    fi

    ''

    + lib.optionalString (conf != null) ''
      cp -f ${configFile} $SCRIPT_DIR/config.py
    ''

    + ''
    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;

    exec ${pname} "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/clifordjoshy/rofi-ytm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-ytm";
  };
}
