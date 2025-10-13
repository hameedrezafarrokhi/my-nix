{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "leftwm" config.my.window-managers) {

  services.xserver.windowManager.leftwm.enable = true;

};}
