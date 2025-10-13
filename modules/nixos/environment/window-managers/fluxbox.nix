{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "fluxbox" config.my.window-managers) {

  services.xserver.windowManager.fluxbox.enable = true;

};}
