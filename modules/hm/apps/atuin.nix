{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.atuin.enable) {

  programs.atuin = {

    package = pkgs.atuin;
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

   #themes = { };

    forceOverwriteSettings = false;
    settings = {
      style = "full";
    };

    flags = [
     #"--disable-ctrl-r"
      "--disable-up-arrow"
    ];

    daemon = {
      enable = false;
     #logLevel = null;
    };

  };

};}
