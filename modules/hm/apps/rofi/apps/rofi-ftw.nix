{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "rofi-ftw";
  version = "2022-06-20";

  src = fetchFromGitHub {
    owner = "BelkaDev";
    repo = "RofiFtw";
    rev = "f2775b10dde60ae4a37f08817d383c2888cd5d69";
    sha256 = "07zz0r2vxygdzln3s3kn0hnqlj32ld1rshwdqp3xmp807l01sqwr";
  };

  dontBuild = true;

  installPhase = ''

    mkdir -p $out/bin

    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${pname}"
    MAIN_SCRIPT="$SCRIPT_DIR/suggest"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${src}/* "$SCRIPT_DIR/"
    fi

    chmod -R u+rw "$SCRIPT_DIR"

    rm -rf $SCRIPT_DIR/src

    chmod +x $MAIN_SCRIPT
    chmod +x $SCRIPT_DIR/handler

    exec $MAIN_SCRIPT "$@"

    EOF

    chmod +x $out/bin/${pname}

  '';

  meta = with lib; {
    homepage = "https://github.com/BelkaDev/RofiFtw";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "RofiFtw";
  };
}
