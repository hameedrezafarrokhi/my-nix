{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "ragnarwm" config.my.window-managers) {

  services.xserver.windowManager.ragnarwm = {

    enable = true;
    package = pkgs.ragnarwm;

  };

};}
