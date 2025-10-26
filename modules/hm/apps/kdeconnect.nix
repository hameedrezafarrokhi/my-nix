{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.kdeconnect.enable) {

  services.kdeconnect = {

    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
    indicator = true;

  };

};}
