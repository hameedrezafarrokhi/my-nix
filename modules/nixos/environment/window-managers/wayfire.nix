{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (builtins.elem "wayfire" config.my.window-managers) {

  programs.wayfire = {
    enable = true;
    package = pkgs.wayfire;
    xwayland.enable = true;
    plugins = config.home-manager.users.${admin}.wayland.windowManager.wayfire.plugins;
  };

};}
