{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "twm" config.my.window-managers) {

  services.xserver.windowManager.twm.enable = true;

};}
