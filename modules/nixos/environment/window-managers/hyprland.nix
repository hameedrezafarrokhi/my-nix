{ inputs, config, pkgs, lib, system, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland" config.my.window-managers) {

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd.setPath.enable = true;
    withUWSM = false;
  };

  programs.uwsm = {
    enable = true;
    package = pkgs.uwsm;
    waylandCompositors = { };
  };

  services = {
    hypridle = {
      enable = true;
      package = pkgs.hypridle;
    };
  };
  programs = {
    hyprlock = {
      enable = true;
      package = pkgs.hyprlock;
    };
  };

  environment.systemPackages = with pkgs; [
    hyprpicker
    hyprshot
    hyprsunset

    waybar               ##Wayland Status bar
   #gbar                 ##Wayland Status bar (Another)
    eww                  ##Wayland Status bar with widgets (Another)
    yambar
   #dunst                ##Hyprland notification daemon
    hyprpaper            ##Hyprland Wallpaper manager
   #swaybg               ##Hyprland Wallpaper manager (Another)
   #wpaperd              ##Hyprland Wallpaper manager (Another)
   #mpvpaper             ##Hyprland Wallpaper manager (Another)
   #swww                 ##Hyprland Wallpaper manager (Another)
    rofi                 ##Hyprland launcher menu
   #wofi                 ##Hyprland launcher menu in gtk
    networkmanagerapplet #Network manager applet for bar
   #hyprgui              #Hyprland GUI App
   #hyprshade            #Hyprland shade configuration tool
    wl-clipboard         ##Sway clipboard copy/paste
    cliphist

    # ax shell
    gnome-bluetooth
    grimblast
   #nvtopPackages.full
    nvtopPackages.amd
   #nvtopPackages.nvidia
    tmux                     # add options later WARNING
    wlinhibit
    psutils
    gobject-introspection
    imagemagick
    libnotify
    playerctl
    swappy
    tesseract
    upower
    vte
    webp-pixbuf-loader

   #(python3.withPackages (ps: with ps; [
   #   pygobject3
   #   numpy
   #   ijson
   #   pillow
   #   pywayland
   #   requests
   #   setproctitle
   #   toml
   #   watchdog
   #   fabric
   #   glib.dev
   #   glib.out
   #   gobject-introspection
   #   python-uinput
   #]))
   #python313Packages.pygobject3
   #python313Packages.numpy
   #python313Packages.ijson
   #python313Packages.pillow
   #python313Packages.pywayland
   #python313Packages.requests
   #python313Packages.setproctitle
   #python313Packages.toml
   #python313Packages.watchdog
   #(glib.override { withIntrospection = true; })
   #
   #(nur.repos.HeyImKyu.run-widget.override {
   #  extraPythonPackages = with python3Packages; [
   #    ijson
   #    pillow
   #    psutil
   #    requests
   #    setproctitle
   #    toml
   #    watchdog
   #    thefuzz
   #    numpy
   #    chardet
   #  ];
   #  extraBuildInputs = [
   #    nur.repos.HeyImKyu.fabric-gray
   #    networkmanager
   #    networkmanager.dev
   #    playerctl
   #    vte
   #  ];
   #})
   #
   #nur.repos.HeyImKyu.fabric-cli

  ]
 #++ [ fabric ]
 #++ [ inputs.gray.packages.${system}.default ]
  ;



 #environment.sessionVariables = {
 #  GI_TYPELIB_PATH = "${pkgs.glib.out}/lib/girepository-1.0";
 #};


};}

#, python3Packages
# --prefix PYTHONPATH : "${python3.pkgs.makePythonPath pythonPath}" \
#$GI_TYPELIB_PATH:
#       --set GI_TYPELIB_PATH "$GI_TYPELIB_PATH:${glib}/lib/girepository-1.0:${gtk3}/lib/girepository-1.0:${gobject-introspection}/lib/girepository-1.0" \
