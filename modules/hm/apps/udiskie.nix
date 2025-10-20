{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.udiskie.enable) {

  services.udiskie = {
    enable = true;
    package = pkgs.udiskie;
    automount = true;
    notify = true;
    tray = "auto"; # one of "always", "auto", "never"
   #settings = { };
  };

};}
