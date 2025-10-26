{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.crystal-dock.enable) {

  home.packages = [
    pkgs.crystal-dock
  ];

};}
