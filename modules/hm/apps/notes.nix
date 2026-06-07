{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.notes.enable) {

  home.packages = [
    pkgs.sticky-notes
    pkgs.sticky
    pkgs.xpad
  ];

  dconf.settings = {

    "com/vixalien/sticky" = {
     #default-height = 312;
     #default-width = 626;
      show-all-notes=false;
    };

    "org/x/sticky" = {
     #active-group = "'Group 1'";
      automatic-backups = false;
      autostart = false;
      autostart-notes-visible = false;
     #backup-interval = "uint32 24";
     #default-height = "uint32 200";
     #default-width= "uint32 250";
      desktop-window-state = false;
     #first-run = false;
      font = "'Comic Sans MS 14'";
     #latest-backup = "uint32 1780790557";
     #old-backups-max = "uint32 7";
      show-in-taskbar = false;
      show-in-tray = true;
      show-manager = false;
    };

  };

};}
