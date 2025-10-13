{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "ratpoison" config.my.window-managers) {

  services.xserver.windowManager.ratpoison.enable = true;

};}
