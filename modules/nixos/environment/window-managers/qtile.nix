{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "qtile" config.my.window-managers) {

  services.xserver.windowManager.qtile = {
    enable = true;
    package = pkgs.python3.pkgs.qtile;
    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
      qtile-bonsai
    ];
   #configFile = ./your_config.py;
  };

};}
