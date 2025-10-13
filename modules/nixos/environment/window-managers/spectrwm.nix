{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "spectrwm" config.my.window-managers) {

  services.xserver.windowManager.spectrwm.enable = true;

};}
