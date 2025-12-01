{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.htop.enable) {

  programs.htop = {
    enable = true;
    package = pkgs.htop;
   #settings = {};
  };

};}
