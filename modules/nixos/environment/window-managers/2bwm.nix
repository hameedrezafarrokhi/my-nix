{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "2bwm" config.my.window-managers) {

  services.xserver.windowManager."2bwm".enable = true;

};}
