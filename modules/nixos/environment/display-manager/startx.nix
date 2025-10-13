{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.tty.startx.enable) {

  services.xserver.enable = true;

  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true;
   #extraCommands = "";
  };

};}
