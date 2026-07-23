{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.taskwarrior.enable) {

  programs.taskwarrior = {

    enable = true;
    package = pkgs.taskwarrior3; # pkgs.taskwarrior2
    dataLocation = "$XDG_DATA_HOME/task";

   #config = { };
   #extraConfig = '' '';

   #colorTheme = "dark-blue-256";

  };

  services.taskwarrior-sync = {
    enable = true;
    package = config.programs.taskwarrior.package;
   #frequency = "*:0/5";
    frequency = "0/6:00";
  };

  home.packages = [
    pkgs.vit
    pkgs.tasknc
    pkgs.taskopen
    pkgs.taskwarrior-tui
    pkgs.tasksh
   #pkgs.taskchampion-sync-server # for taskwarrior3
   #pkgs.taskserver # for taskwarrior2
  ];

};}
