{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "fvwm2" config.my.window-managers) {

  services.xserver.windowManager.fvwm2 = {

    enable = true;
    gestures = true;

  };

};}
