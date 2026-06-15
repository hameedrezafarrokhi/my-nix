{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "hackedbox" config.my.window-managers) {

  services.xserver.windowManager.hackedbox.enable = true;

};}
