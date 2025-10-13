{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, fetchgit
, unzip
, makeWrapper
, python3
, python3Full
#, python312Full
#, python312
#, python312Packages
, python3Packages
, brightnessctl
, cava
, cliphist
, gnome-bluetooth
, gobject-introspection
, gpu-screen-recorder
, grimblast
, gtk3
, glib
, wrapGAppsHook
, hyprland
, hypridle
, hyprlock
, hyprpicker
, hyprshot
, hyprsunset
, imagemagick
, libnotify
, noto-fonts-emoji
, nvtopPackages
, playerctl
, swappy
, tesseract
, tmux
, upower
, vte
, webp-pixbuf-loader
, wl-clipboard
, nerdfonts
, matugen
, swww
, uwsm

, inputs
, nur
, callPackage
, pkg-config
, cinnamon-desktop
, cairo
, gtk-layer-shell
, libdbusmenu-gtk3
, webkitgtk_4_1
, wayland
, networkmanager
, networkmanagerapplet
, gdk-pixbuf
, vala
,

}:

let

  system = "x86_64-linux";
 #fabric = callPackage "${inputs.fabric}/default.nix" { };
 #fabric-cli = nur.repos.HeyImKyu.fabric-cli;
 #gray = inputs.gray.packages."x86_64-linux".default;
  fabric = callPackage ./fabric.nix { };
  fabric-cli = callPackage ./fabric-cli.nix { };
  gray = callPackage ./gray.nix { };
  ax-shell-src = inputs.ax-shell;

in

stdenv.mkDerivation rec {
  pname = "ax-shell";
  version = "r130.fcf3323";

  src = ax-shell-src;

  zed-sans = fetchurl {
    url = "https://github.com/zed-industries/zed-fonts/releases/download/1.2.0/zed-sans-1.2.0.zip";
    sha256 = "sha256-64YcNcbxY5pnR5P3ETWxNw/+/JvW5ppf9f/6JlnxUME=";
  };

  nativeBuildInputs = [ unzip makeWrapper wrapGAppsHook gobject-introspection pkg-config cinnamon-desktop python3 python3Full ];
  propagatedBuildInputs = buildInputs;
  buildInputs = [
    brightnessctl
    cava
    cliphist
    fabric-cli
    gnome-bluetooth
    gobject-introspection
    gpu-screen-recorder
    gray
    gtk3
    glib
    hyprland
    hypridle
    hyprlock
    hyprpicker
    hyprshot
    hyprsunset
    imagemagick
    libnotify
    matugen
    noto-fonts-emoji
    nvtopPackages.amd
    nvtopPackages.intel
    nvtopPackages.nvidia
    nvtopPackages.v3d
    playerctl
    fabric
    python3
    python3Full
    python3Packages.pygobject3
    python3Packages.pygobject-stubs
    python3Packages.ijson
    python3Packages.numpy
    python3Packages.pillow
    python3Packages.psutil
    python3Packages.pywayland
    python3Packages.requests
    python3Packages.setproctitle
    python3Packages.toml
    python3Packages.watchdog
    python3Packages.loguru
    python3Packages.pycairo
    python3Packages.click
    python3Packages.pip
    python3Packages.build
    python3Packages.installer
    python3Packages.setuptools
    python3Packages.requests
    python3Packages.dbus-python
    python3Packages.pydbus
    python3Packages.sdbus-networkmanager
    python3Packages.thefuzz
    python3Packages.chardet
    networkmanager
    networkmanager.dev
    networkmanagerapplet
    swappy
    swww
    tesseract
    tmux
    upower
    uwsm
    vte
    webp-pixbuf-loader
    wl-clipboard
    pkg-config
    cinnamon-desktop
    cairo
    gtk-layer-shell
    libdbusmenu-gtk3
    webkitgtk_4_1
    wayland
    vala
  ];
   dependancies = buildInputs;

  fabricPythonPath = "${fabric}/lib/python3.13/site-packages";
  pythonPath = [ fabricPythonPath ] ++ (with python3Packages; [
    pygobject3
    pygobject-stubs
    ijson
    numpy
    pillow
    psutil
    pywayland
    requests
    setproctitle
    toml
    watchdog
    loguru
    pycairo
    click
    pip
    build
    installer
    setuptools
    requests
    dbus-python
    pydbus
    sdbus-networkmanager
    thefuzz
    chardet
  ]);

 #postPatch = ''
 #sed -i 's/default_value=Layer.TOP/default_value=2/' widgets/wayland.py
 #sed -i 's/default_value=KeyboardMode.NONE/default_value=0/' widgets/wayland.py
 #sed -i '12i\from gi.repository import GObject; from widgets.wayland import Layer, KeyboardMode, Edge, WaylandWindowExclusivity; Layer; KeyboardMode; Edge; WaylandWindowExclusivity' main.py
 #sed -i '1i\from gi.repository import NM' services/network.py
 #'';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ax-shell
    cp -r assets config modules scripts services styles utils widgets LICENSE install.sh main.css uninstall.sh version.json main.py README.md $out/share/ax-shell/

    mkdir -p $out/bin
    makeWrapper ${python3}/bin/python $out/bin/ax-shell \
      --add-flags "$out/share/ax-shell/main.py" \
      --prefix PYTHONPATH : "${fabric}/lib/python3.13/site-packages:${python3.pkgs.makePythonPath (with python3Packages; [
          pygobject3
          pygobject-stubs
          ijson
          numpy
          pillow
          psutil
          pywayland
          requests
          setproctitle
          toml
          watchdog
          loguru
          pycairo
          click
          pip
          build
          installer
          setuptools
          requests
          dbus-python
          pydbus
          sdbus-networkmanager
          thefuzz
          chardet
        ])}" \
      --prefix PATH : "${lib.makeBinPath buildInputs}" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH:${gray}/lib/girepository-1.0" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

    mkdir -p $out/share/fonts/zed-sans
    temp_dir=$(mktemp -d)
    unzip -o ${zed-sans} -d "$temp_dir"
    cp -r "$temp_dir"/* $out/share/fonts/zed-sans/
    rm -rf "$temp_dir"

    mkdir -p $out/share/fonts/tabler-icons
    cp -r assets/fonts/* $out/share/fonts/tabler-icons/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A feature-rich, configurable, and elegant shell for Linux systems";
    homepage = "https://github.com/Axenide/ax-shell";
   #license = licenses.mit;
   #platforms = platforms.linux;
   #maintainers = [ ];
  };
}
