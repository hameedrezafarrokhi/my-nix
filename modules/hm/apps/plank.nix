{ config, pkgs, lib, ... }:

  with lib.hm.gvariant;

{ config = lib.mkIf (config.my.apps.plank.enable) {

  dconf.settings = {

   "net/launchpad/plank/docks/dock1" = {
     alignment = "center";
     current-workspace-only = false;
     dock-items = ["org.kde.dolphin.dockitem" "kitty.dockitem" "brave-browser.dockitem"];
     hide-mode = "window-dodge";
     icon-size = 32;
     lock-items = false;
     monitor = "";
     offset = 0;
     pinned-only = false;
     position = "left";
     pressure-reveal = false;
     theme = "Transparent";
     zoom-enabled = true;
     zoom-percent = 140;
   };

  };

  home.packages = [
    pkgs.plank
  ];

};}
