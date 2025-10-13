{ config, lib, pkgs, ... }:

let

  cfg = config.my.x11;

in

{

  options.my.x11.enable = lib.mkEnableOption "x11 settings";

  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;

    services.xserver.displayManager.startx = {
      enable = true;
      generateScript = true;
     #extraCommands = '' '';
    };

    environment.systemPackages = [ pkgs.wayback-x11 ];

  };

}
