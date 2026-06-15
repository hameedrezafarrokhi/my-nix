{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "smallwm" config.my.window-managers) {

  services.xserver.windowManager.smallwm.enable = true;

};}
