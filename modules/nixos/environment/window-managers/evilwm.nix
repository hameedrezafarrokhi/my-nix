{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "evilwm" config.my.window-managers) {

  services.xserver.windowManager.evilwm.enable = true;

};}
