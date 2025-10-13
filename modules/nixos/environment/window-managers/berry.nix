{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "berry" config.my.window-managers) {

  services.xserver.windowManager.berry.enable = true;

};}
