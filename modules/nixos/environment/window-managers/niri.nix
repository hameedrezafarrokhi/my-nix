{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "niri" config.my.window-managers) {

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = [

    pkgs.nirius
    pkgs.xwayland-satellite
    pkgs.swww

  ];

};}
