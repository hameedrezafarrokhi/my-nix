{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "mlvwm" config.my.window-managers) {

  services.xserver.windowManager.mlvwm = {

    enable = true;
   #configFile = ;

  };

};}
