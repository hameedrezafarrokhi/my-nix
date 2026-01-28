{ config, lib, pkgs, mypkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.theming.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #base16-schemes
   #base16-shell-preview
   #base16-universal-manager
   #flavours

   #nordic                        ##Nordic theme for kde
   #kdePackages.breeze-grub       ##Breeze for grub

    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum

    libsForQt5.qt5ct
    kdePackages.qt6ct

    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtbase
   #libsForQt5.qt5.qtdeclarative
    libsForQt5.kdeclarative
    libsForQt5.qt5.qtwayland
    libsForQt5.plasma-wayland-protocols
    libsForQt5.kwayland
   #libsForQt5.kwayland-integration
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qt5.qtsvg

    kdePackages.qtbase.dev

   #catppuccin
   #catppuccin-kde
   #catppuccin-gtk
   #catppuccin-sddm
   #catppuccin-sddm-corners
   #catppuccin-papirus-folders
   #catppuccin-grub
   #catppuccin-qt5ct
   #catppuccin-kvantum
   #catppuccin-cursors
   #catppuccinifier-gui
   #catppuccinifier-cli
   #catppuccin-whiskers
   #catppuccin-catwalk

    papirus-folders

   #libsForQt5.bismuth

    # GRUB Themes
   #catppuccin-grub

    gowall

  ] ) config.my.software.theming.exclude)

   ++

  config.my.software.theming.include

   ++

  [
   #mypkgs.stable.gradience                     ##Theming for gtk2/3/4
  ];

};}
