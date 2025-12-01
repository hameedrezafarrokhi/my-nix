{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.tty.sx.enable) {

  services.xserver.enable = true;

  services.xserver.displayManager.sx = {
    enable = true;
    package = pkgs.sx;
    addAsSession = false;
  };

};}
