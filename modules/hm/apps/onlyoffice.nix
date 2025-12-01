{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.onlyoffice.enable) {

  programs.onlyoffice = {
    enable = true;
    package = pkgs.onlyoffice-desktopeditors;
   #settings = '' '';
  };

};}
