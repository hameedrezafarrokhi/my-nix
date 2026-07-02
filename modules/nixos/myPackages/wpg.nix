{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
}:

let

  pythonEnv = python3.withPackages (ps: with ps; [
    xpybutil
    numpy
    tqdm
    pillow
    setuptools
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "nrbjerg";
    repo = "wpg";
   #rev = "master";
    rev = "71027af81c6812a704d10862f7ee9d90ed33674a";
    hash = "sha256-wdyMOUYQ9Eq6u+aavU8WpqrLE4pAIL0sAE0etNKlpsI=";
  };

  scriptRepo2 = fetchFromGitHub {
    owner = "fayesafe";
    repo = "wpg";
   #rev = "master";
    rev = "71027af81c6812a704d10862f7ee9d90ed33674a";
    hash = "sha256-wdyMOUYQ9Eq6u+aavU8WpqrLE4pAIL0sAE0etNKlpsI=";
  };

in

stdenv.mkDerivation rec {
  pname = "wpg-py";
  ename = "wpg";
  version = "2022-08-30";

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
    cat > $out/bin/${ename}-wall << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}-wall"
    MAIN_SCRIPT="$SCRIPT_DIR/random_walk.py"

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

    chmod +x $out/bin/${ename}-wall

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${ename}-wall.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=${ename}-wall
    Comment=random wallpaper generator
    Exec=$out/bin/${ename}-wall
    EOF



    # Create Launcher 2
    cat > $out/bin/${ename}-grad << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}-grad"
    MAIN_SCRIPT="$SCRIPT_DIR/wpg.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo2}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type f -exec chmod 644 {} \;
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} \;
    find "$SCRIPT_DIR" -name "*.py" -exec chmod 644 {} \;

    exec ${pname} "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/${ename}-grad

    # Install desktop file 2
    mkdir -p $out/share/applications
    cat > $out/share/applications/${ename}-grad.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=${ename}-grad
    Comment=random wallpaper generator
    Exec=$out/bin/${ename}-grad
    EOF
  '';

 #homepage2 = "https://github.com/fayesafe/wpg";
  meta = with lib; {
    description = " ";
    homepage = "https://github.com/nrbjerg/wpg";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
