{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "labwc" config.my.window-managers) {

  programs.labwc = {
    enable = true;
    package = pkgs.labwc;
  };

  environment.systemPackages = [

    pkgs.swww

  ];

};}
