{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "mwm" config.my.window-managers) {

  services.xserver.windowManager.mwm.enable = true;

};}
