{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "lwm" config.my.window-managers) {

  services.xserver.windowManager.lwm.enable = true;

};}
