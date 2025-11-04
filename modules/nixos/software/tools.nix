{ config, lib, pkgs, mypkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.tools.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    xdotool

    onboard                       ##Onscreen keyboard

   #(flameshot.override {
   #   enableWlrSupport = true;
   #   enableMonochromeIcon = true;
   #})
    ksnip                         ##Screenshots
    gradia                        ##Screenshots

    kdePackages.kruler            ##KDE ruler

   #crow-translate                ##Translation
   #dialect                       ##Translation

   #ulauncher                     ##Keyboard Launcher
   #albert                        ##Keyboard Launcher

    kdePackages.kunitconversion   ##KDE unit converter krunner plugin
    convertall                    ##Unit converter
    valuta                        ##Currency converter

    clairvoyant                   ##Ask the 8ball!
    chance                        ##Roll the dice!

    eyedropper                    ##Colorpicker

    gnome-characters              ##Gnome emojis
    gnome-decoder                 ##QR code reader
    gnome-clocks                  ##Gnome clock app
    gnome-calendar                ##Gnome calendar
    gnome-weather                 ##Gnome weather
    gnome-maps                    ##Gnome maps

    mousam                        ##Persian Weather
    kdePackages.kweather          ##KDE weather

    keypunch                      ##Train keyboard

    kdePackages.ktimer            ##Task Timer KDE
    kdePackages.kalarm
    kshutdown
    kdePackages.kcron
    peaclock                       ##CLI Clock and Task Timer utils

    dxvk
    dxvk_2
    vulkan-tools
    libva-utils
    clinfo
    vdpauinfo
   #driversi686Linux.vdpauinfo

   #libgbm

   #######################################################################

   # UNCATEGORIZED

    xorg.xeyes                    ##Detect wich apps use wayland
    wayland-logout

    # Astronomy
   #kstars
   #celestia
   #astroterm

    devtoolbox
    emblem
   #blesh

   #quickshell

    wallust
    swww

    tokei

    gpu-screen-recorder-gtk
    matugen
    fltk
    brightnessctl
    ddcutil

    feishin
   #CuboCore.coretime

  ] ) config.my.software.tools.exclude)

   ++

  config.my.software.tools.include

   ++

  [
    mypkgs.stable.ulauncher
    mypkgs.stable.CuboCore.coretime
  ]

   #++ [(pkgs.callPackage "${inputs.windscribe}/windscribe/package.nix" { })]
   #++ [((pkgs.extend (final: prev: {openssl_3_3 = prev.openssl_3_5;})).callPackage "${inputs.windscribe}/windscribe.nix" { } )]
   #++ [(pkgs.callPackage "${inputs.windscribe}/windscribe.nix" { })]

    ++ [(pkgs.callPackage ../myPackages/avvie.nix { })]
    ++ [(pkgs.callPackage ../myPackages/vboard.nix { })]
    ++ [(pkgs.callPackage ../myPackages/timeswitch.nix { })]
   #++ [(pkgs.callPackage ../myPackages/ax-shell.nix { inherit inputs; })]
   #++ [(pkgs.callPackage ../myPackages/ax-shell-2.nix { })]
   #++ [(pkgs.callPackage ../myPackages/fabric.nix { })]
   #++ [(pkgs.callPackage ../myPackages/fabric-cli.nix { })]
   #++ [(pkgs.callPackage ../myPackages/gray.nix { })]
   #++ [(pkgs.callPackage ../myPackages/run-widget.nix { })]
  ;

  programs = {

    java = {      #For Minecraft
      enable = true;
      binfmt = true;
     #package = pkgs.jdk;
    };

  };

};}
