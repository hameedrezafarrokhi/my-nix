{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "tinywm" config.my.window-managers) {

  services.xserver.windowManager.tinywm.enable = true;

};}
