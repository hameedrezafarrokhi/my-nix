{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "cwm" config.my.window-managers) {

  services.xserver.windowManager.cwm.enable = true;

};}
