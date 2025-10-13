{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "windowlab" config.my.window-managers) {

  services.xserver.windowManager.windowlab.enable = true;

};}
