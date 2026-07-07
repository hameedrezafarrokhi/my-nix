{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, wrapGAppsHook3
, glib
, gobject-introspection
, libx11
, libxft
, libxrandr
, libxrender
, libxres
, libxcursor
, libxext
, libxi
, libxinerama
, libxmu
, libxpm
, libxmp
, libxt
, libxdamage
, libxdmcp
, libxcomp
, libxcomposite
, libxkbcommon

, libxcb
, libxcb-wm
, libxcb-util
, libxcb-render-util
, libxcb-keysyms
, libxcb-image
, libxcb-errors
, libxcb-cursor

, fontconfig
, freetype

, pkg-config

, gtk3
, gtk-layer-shell
, cairo
, libdbusmenu-gtk3
, gdk-pixbuf
, librsvg
, gnome-bluetooth
, cinnamon-desktop

, callPackage
, fetchurl

, extraPythonPackages ? [ ]
, extraBuildInputs ? [ ]

, libnma
, networkmanager
, matugen
, playerctl
, feh
, brightnessctl
, roboto-flex
, material-symbols
, googlesans-code
, libnotify
, sass
, cliphist
}:

let
  pygobject_3_50 = python3Packages.pygobject3.overrideAttrs (old: {
    version = "3.50.0";
    src = fetchurl {
      url = "mirror://gnome/sources/pygobject/3.50/pygobject-3.50.0.tar.xz";
      hash = "sha256-jYNudbWogdRX7hYiyuSjK826KKC6ViGTrbO7tHJHIhI=";
    };
  });
  fabric = callPackage ./fabric.nix { };
  fabric-cli = callPackage ./fabric-cli.nix { };
  libgray = callPackage ./gray.nix { };
 #systemd = callPackage ./cysystemd.nix { };
  pythonEnv = python3Packages.python.withPackages (
    ps:
    with ps;
    [
      click
      pycairo
      pygobject_3_50
      loguru
      psutil
      pygobject-stubs
     #fabric

      certifi
      cffi
      charset-normalizer
     #expressive-shapes
      i3ipc
      idna
      loguru
      pillow
      pulsectl
      pycparser
      pyopengl
      python-pam
      xlib
      requests
      setproctitle
      six
      typer
      urllib3

      dbus-python
      emoji
      pkgconfig
      pydantic
      pytesseract
      pystemd
      systemd-python
      systemdunitparser
    ]
    ++ extraPythonPackages
    ++ [ fabric
        #systemd
       ]
  );

  scriptRepo = fetchFromGitHub {
    owner = "meowrch";
    repo = "mewline";
    rev = "5c766fa332fa113af6af59b998b52a0c36cade62";
    sha256 = "0lmr0rlfzssg76vi7z6hnbmk8hyi5w578njqs6q5nk65dhgvshsz";
  };

  ename = "mewline";

in

stdenv.mkDerivation rec {
  pname = "mewline-py";
  version = "2026-06-02";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype

    gtk3
    gtk-layer-shell
    cairo
    gobject-introspection
    libdbusmenu-gtk3
    gdk-pixbuf
    librsvg
    gnome-bluetooth
    cinnamon-desktop

    libgray
    fabric-cli

    libnma
    networkmanager
    matugen
    playerctl
    feh
    brightnessctl
    libnotify
    roboto-flex
    material-symbols
    googlesans-code

    cliphist
    sass
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
      --prefix PYTHONPATH : "${pythonEnv}/${python3Packages.python.sitePackages}"

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/run.py"

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
    Comment=x11 fabric shell
    Exec=$out/bin/${ename}
    EOF

  '';

  meta = with lib; {
    homepage = "https://github.com/meowrch/mewline";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mewline";
  };
}
