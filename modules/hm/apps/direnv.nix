{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.direnv.enable) {

  programs.direnv = {

    enable = true;
    package = pkgs.direnv;

    enableBashIntegration = true;
   #enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;

    mise = {
      enable = true;
      package = pkgs.mise;
    };

    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };

    silent = false;
   #config = { };
   #stdlib = '' '';

  };

};}
