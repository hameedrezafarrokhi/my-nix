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
  expressive-shapes = callPackage ./expressive-shapes.nix { };
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
      fabric

      certifi
      cffi
      charset-normalizer
      expressive-shapes
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
    ]
    ++ extraPythonPackages
  );

  scriptRepo = fetchFromGitHub {
    owner = "amansxcalibur";
    repo = "zenith-shell";
    rev = "5da1c733823ff758da8af295086f8798d6bdcf01";
    sha256 = "0daril3jx8i73xkcxm0pf7mkqzd93z4xkn3szzh1x9lgsa0f6xd9";
  };

  ename = "zenith-shell";

in

stdenv.mkDerivation rec {
  pname = "zenith-shell-py";
  version = "2026-07-02";

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
    MAIN_SCRIPT="$SCRIPT_DIR/main.py"

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
    homepage = "https://github.com/amansxcalibur/zenith-shell";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zenith-shell";
  };
}
