{
  python3,
  stdenv,
  gtk3,
  gtk-layer-shell,
  cairo,
  gobject-introspection,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  gnome-bluetooth,
  cinnamon-desktop,
  librsvg,
  extraPythonPackages ? [ (callPackage ./fabric.nix { }) ],
  extraBuildInputs ? [ (callPackage ./gray.nix { }) ],
  callPackage,
  networkmanager,
  playerctl,

}: let

  system = "x86_64-linux";
  python-fabric = callPackage ./fabric.nix { };
  fabric = callPackage ./fabric.nix { };
  gray = callPackage ./gray.nix { };

  python = python3.withPackages (
    ps:
      with ps;
        [
          click
          pycairo
          pygobject3
          loguru
          psutil
          python-fabric
          fabric
          pygobject-stubs
          ijson
          pillow
          psutil
          requests
          setproctitle
          toml
          watchdog
          thefuzz
          numpy
          chardet
        ]
        ++ extraPythonPackages
        ++ [ python-fabric fabric ]
  );
in
  stdenv.mkDerivation {
    name = "run-widget";
    propagatedBuildInputs =
      [
        gtk3
        gtk-layer-shell
        cairo
        gobject-introspection
        libdbusmenu-gtk3
        gdk-pixbuf
        librsvg
        gnome-bluetooth
        cinnamon-desktop
        gray
        networkmanager
        networkmanager.dev
        playerctl
      ]
      ++ extraBuildInputs;
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/run-widget << EOF
      #!/bin/sh
      GI_TYPELIB_PATH=$GI_TYPELIB_PATH \
      GDK_PIXBUF_MODULE_FILE="$GDK_PIXBUF_MODULE_FILE" \
      ${python.interpreter} "\$@"
      EOF
      chmod +x $out/bin/run-widget
    '';
    meta.mainProgram = "run-widget";
  }
