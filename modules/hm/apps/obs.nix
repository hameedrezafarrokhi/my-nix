{ config, pkgs, lib,  ... }:

{
config = lib.mkIf (config.my.apps.obs.enable) {

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio;
   #plugins = [ pkgs.obs-studio-plugins.wlrobs ];
  };

};
}
