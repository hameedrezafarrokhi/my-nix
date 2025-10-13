{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.display-manager == "ly") {

  services.xserver.enable = true;

  services.displayManager.ly = {

    enable = true;
    package = pkgs.ly;
    x11Support = true;
   #settings = {
   #  load = false;
   #  save = false;
   #};

  };

};}
