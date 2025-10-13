{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "hypr" config.my.window-managers) {

  services.xserver.windowManager.hypr.enable = true;

};}
