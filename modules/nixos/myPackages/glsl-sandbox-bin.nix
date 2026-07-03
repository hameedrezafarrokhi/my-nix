{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {

  pname = "glsl-sandbox";
  version = "2026-07-03";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "d2df350b3bb6445b5453606908dc91ec4bb99b99";
    sha256 = "1ni6szwl7lsx31y2g9bz61da51dpsxffldf1v5nn9qqxs7c3v304";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/glsl-sandbox $out/bin
    cp -r ${src}/glsl-sandbox/* $out/share/glsl-sandbox
    #ln -sf $out/share/glsl-sandbox/glslsandbox $out/bin/glslsandbox
    #ln -sf $out/share/glsl-sandbox/glsladmin $out/bin/glsladmin

    # Create Launcher
    cat > $out/bin/glslsandbox << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.local/share/glsl-sandbox"
    MAIN_SCRIPT="$SCRIPT_DIR/glslsandbox"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${src}/glsl-sandbox/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    chmod +x $MAIN_SCRIPT

    cd "$SCRIPT_DIR"

    exec "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/glslsandbox


    # Create Launcher 2
    cat > $out/bin/glsladmin << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.local/share/glsl-sandbox"
    MAIN_SCRIPT="$SCRIPT_DIR/glsladmin"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${src}/glsl-sandbox/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"
    chmod +x $MAIN_SCRIPT

    cd "$SCRIPT_DIR"

    exec "$MAIN_SCRIPT" "$@"

    EOF

    chmod +x $out/bin/glsladmin


  '';

  meta = {
    description = " ";
    homepage = "https://github.com/mrdoob/glsl-sandbox";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "glsl-sandbox";
  };
}
