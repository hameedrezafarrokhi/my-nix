{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "icewm" config.my.window-managers) {

  services.xserver.windowManager.icewm.enable = true;

};}
