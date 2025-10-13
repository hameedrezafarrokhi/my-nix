{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "miracle-wm" config.my.window-managers) {

  programs.wayland.miracle-wm.enable = true;

};}
