{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "fvwm3" config.my.window-managers) {

  services.xserver.windowManager.fvwm3.enable = true;

};}
