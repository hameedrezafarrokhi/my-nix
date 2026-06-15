{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "afterstep" config.my.window-managers) {

  services.xserver.windowManager.afterstep.enable = true;

};}
