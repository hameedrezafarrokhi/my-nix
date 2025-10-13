{ config, pkgs, lib, ... }:

  with lib.hm.gvariant;

{ config = lib.mkIf (config.my.apps.plank.enable) {

  dconf.settings = {

   #"net/launchpad/plank/docks/dock1" = {
   #  alignment = "center";
   #  current-workspace-only = false;
   #  dock-items = [ "org.kde.elisa.dockitem" "org.kde.kmail2.dockitem" "brave-browser.dockitem" "kitty-open.dockitem" "mpv.dockitem" "org.gnome.Calendar.dockitem" "org.kde.gwenview.dockitem" "applications.dockitem" ];
   #  hide-mode = "auto";
   #  icon-size = 24;
   #  lock-items = false;
   #  monitor = "";
   #  offset = 0;
   #  pinned-only = false;
   #  position = "bottom";
   #  pressure-reveal = false;
   #  theme = "Transparent";
   #  zoom-enabled = true;
   #  zoom-percent = 157;
   #};

  };

  home.packages = [
    pkgs.plank
  ];

};}
