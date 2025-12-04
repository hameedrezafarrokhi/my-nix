{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "plasma" config.my.desktops) {

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;      # Disable for a pure Qt 6 system.
    notoPackage = pkgs.noto-fonts;
  };

  environment = {
    systemPackages = with pkgs; [
     #kdePackages.discover ##KDE appstore
      kdePackages.krohnkite
      kdePackages.karousel
     #polonium
      kdePackages.dolphin-plugins
      kdePackages.plasma-integration
      kdePackages.plasma-browser-integration
      kdePackages.kdeplasma-addons
      kdePackages.kguiaddons
      kdePackages.kirigami
      kdePackages.kirigami-gallery
      libsForQt5.kirigami2
      libsForQt5.kirigami-addons
      kdePackages.kirigami-addons
      kdePackages.kwidgetsaddons
      kdePackages.ktextaddons
      kdePackages.kio-extras
      kdePackages.ffmpegthumbs
      kdePackages.kdesdk-thumbnailers
      kdePackages.kdegraphics-thumbnailers
      kdePackages.kimageformats
      kdePackages.qtimageformats
      kdePackages.taglib
      kdePackages.qtbase
      kdePackages.qtdeclarative
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.qtshadertools
      kdePackages.qt5compat
      kdePackages.qtmultimedia
      kdePackages.qtwebview
      kdePackages.qtwebsockets
      kdePackages.qtwebengine
      kdePackages.qtwebchannel
      nur.repos.xddxdd.plasma-smart-video-wallpaper-reborn
     #nur.repos.shadowrz.klassy-qt6
     #plasma-panel-colorizer
      kara
      kdePackages.kwayland-integration
     #kdePackages.kded

      kdePackages.plasma-keyboard

    ];
   #plasma6.excludePackages = [             # Excluding Packages (Not Working)
   #  pkgs.kdePackages.kwallet
   #  pkgs.kdePackages.kwalletmanager
   #  pkgs.kdePackages.kpkpass
   #];
  };

  programs = {

    kde-pim = {
      enable = false;
      kmail = false;
      kontact = false;
      merkuro = false;
    };

  };

 #systemd.user.services.plasma-dolphin = {
 #  description = "Dolphin file manager";
 #  partOf = ["graphical-session.target"];
 #  environment = { XDG_MENU_PREFIX="plasma-"; };
 #  serviceConfig = {
 #    ExecStart = "${pkgs.kdePackages.dolphin}/bin/dolphin --daemon";
 #    BusName="org.freedesktop.FileManager1";
 #    Environment = ["XDG_MENU_PREFIX=plasma-"];
 #    Slice = "background.slice";
 #  };
 #  wantedBy = ["graphical-session.target"];
 #};

};}
