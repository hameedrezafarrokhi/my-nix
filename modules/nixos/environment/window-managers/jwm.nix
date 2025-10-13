{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "jwm" config.my.window-managers) {

  services.xserver.windowManager.jwm.enable = true;

};}
