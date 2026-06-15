{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "nimdow" config.my.window-managers) {

  services.xserver.windowManager.nimdow = {
    enable = true;
    package = pkgs.nimdow;
  };

};}
