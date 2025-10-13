{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "wmderland" config.my.window-managers) {

  services.xserver.windowManager.wmderland = {

    enable = true;
   #extraSessionCommands = '' '';
   #extraPackages = [ ];

  };

};}
