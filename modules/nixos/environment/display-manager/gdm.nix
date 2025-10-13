{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.display-manager == "gdm") {

  services.xserver.enable = true;

  services.xserver.displayManager.gdm = {

    enable = true;
    wayland = true;

    banner = ''Hello :)'';
   #settings = { };
    autoSuspend = true;
    autoLogin.delay = 0;
    debug = false;

  };

};}
