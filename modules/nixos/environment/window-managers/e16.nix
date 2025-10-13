{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "e16" config.my.window-managers) {

  services.xserver.windowManager.e16.enable = true;

};}
