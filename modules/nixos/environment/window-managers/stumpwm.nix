{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "stumpwm" config.my.window-managers) {

  services.xserver.windowManager.stumpwm = {
    enable = true;
    package = pkgs.stumpwm;
  };

};}
