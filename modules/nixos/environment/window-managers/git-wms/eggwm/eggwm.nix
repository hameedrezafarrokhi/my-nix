{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXft,
  libXinerama,
  libXrandr,
  libXrender,
  libXcursor,
  qt5,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "eggwm";
  version = "2022-08-27";

  src = fetchFromGitHub {
    owner = "7b7b";
    repo = "eggwm";
   #rev = "master";
    rev = "4c1725ed1fabcf6fabbf324254ce669f52fc173c";
    sha256 = "02bjmcgcwiy0gsmym8jmmhym8mr93w58rp3fcihd378a02yywg4k";
  };

  env = {
    QT_SELECT=5;
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    libX11
    libXft
    libXinerama
    libXrandr
    libXrender
    libXcursor
    qt5.qtbase
    qt5.qtx11extras
    qt5.qttools
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  postPatch = ''
    substituteInPlace src/config/Config.cpp \
      --replace \
      '"const char* Config::USR_CONFIG_DIR       = "/usr/share/eggwm";' \
      '"const char* Config::USR_CONFIG_DIR       = "$out/share/eggwm";'

    substituteInPlace src/config/Config.cpp \
      --replace \
      'qFatal("/usr/share/eggwm not found, reinstall the application can "' \
      'qFatal("$out/share/eggwm not found, reinstall the application can "'
  '';

  buildPhase = ''
    runHook preBuild
    qmake
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/eggwm
    mkdir -p $out/bin
    install -d $out/share/eggwm
    cp -r data/* $out/share/eggwm
    install -Dm755 eggwm $out/bin/eggwm-unwrapped
    runHook postInstall
  '';

  postFixup = ''
    # Create Launcher
    cat > $out/bin/eggwm << 'EOF'
    #!/usr/bin/env bash

    CONF_DIR="$HOME/.eggwm"

    echo "Config Should Be At $HOME/.eggwm/eggwm.conf"
    echo "example config:"
    echo " "
    echo "[theme]"
    echo "name=default"
    echo " "
    echo " "
    echo "Theme Directory Should Also Be At $HOME/.eggwm/themes/"
    echo "See The Repo For Theme Structure"
    echo "https://github.com/7b7b/eggwm"

    if [ ! -f "$CONF_DIR/eggwm.conf" ]; then
      mkdir -p "$CONF_DIR"
      cp -r /run/current-system/sw/share/eggwm/* $CONF_DIR/
    fi

    exec eggwm-unwrapped "$@"

    EOF

    chmod +x $out/bin/eggwm
  '';

  meta = with lib; {
    homepage = "https://github.com/7b7b/eggwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "eggwm";
  };
}
