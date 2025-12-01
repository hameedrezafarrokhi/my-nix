{ config, pkgs, lib,  ... }:

{ config = lib.mkIf (config.my.apps.mangohud.enable) {

  programs.mangohud = {
    enable = true;
    package = pkgs.mangohud;
   #settings = {};
   #enableSessionWide = true;
   #settingsPerApplication = {};
  };

};}
