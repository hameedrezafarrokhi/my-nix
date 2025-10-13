{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.ludusavi.enable) {

  services.ludusavi = {
    enable = true;
    package = pkgs.ludusavi;
   #frequency = "daily"; # "*-*-* 8:00:00"
   #configFile = null;
   #backupNotification = false;
   #settings = {
   #  backup = {
   #    path = "~/.local/state/backups/ludusavi";
   #  };
   #  language = "en-US";
   #  restore = {
   #    path = "~/.local/state/backups/ludusavi";
   #  };
   #  roots = [
   #    {
   #      path = "~/.local/share/Steam";
   #      store = "steam";
   #    }
   #  ];
   #  theme = "light";
   #};
  };

};}
