{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "wmii" config.my.window-managers) {

  services.xserver.windowManager.wmii.enable = true;

};}
