{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "river" config.my.window-managers) {

  programs.river-classic = {
    enable = true;
    package = pkgs.river-classic;
    xwayland.enable = true;
    extraPackages = with pkgs; [ swaylock foot dmenu ];
  };

};}
