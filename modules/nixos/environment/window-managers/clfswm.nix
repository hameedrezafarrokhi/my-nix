{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "clfswm" config.my.window-managers) {

  services.xserver.windowManager.clfswm = {
    enable = true;
    package = pkgs.sbclPackages.clfswm;
  };

};}
