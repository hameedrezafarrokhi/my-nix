{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "windowmaker" config.my.window-managers) {

  services.xserver.windowManager.windowmaker.enable = true;

};}
