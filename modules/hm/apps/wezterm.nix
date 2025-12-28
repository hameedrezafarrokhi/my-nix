{ config, pkgs, lib,  ... }:

{ config = lib.mkIf (config.my.apps.wezterm.enable) {

  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
    enableBashIntegration = true;
    enableZshIntegration = true;
   #extraConfig = '' '';
   #colorSchemes = { };
  };

};}
