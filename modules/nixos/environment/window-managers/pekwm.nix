{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "pekwm" config.my.window-managers) {

  services.xserver.windowManager.pekwm.enable = true;

};}
