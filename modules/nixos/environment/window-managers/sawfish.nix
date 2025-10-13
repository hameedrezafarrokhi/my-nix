{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "sawfish" config.my.window-managers) {

  services.xserver.windowManager.sawfish.enable = true;

};}
