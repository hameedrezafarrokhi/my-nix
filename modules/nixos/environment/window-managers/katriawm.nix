{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "katriawm" config.my.window-managers) {

  services.xserver.windowManager.katriawm = {
    enable = true;
    package = pkgs.katriawm;
  };

  environment.systemPackages = [
    pkgs.bevelbar
  ];

};}
