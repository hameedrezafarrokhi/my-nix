{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "xfce" config.my.desktops) {

  services.xserver.desktopManager.xfce = {

    enable = true;
    enableXfwm = true;
    enableWaylandSession = true;
    waylandSessionCompositor = "labwc --startup"; # "wayfire"
    noDesktop = false;
    enableScreensaver = true;

  };

  environment.xfce.excludePackages = [ ];
  programs.xfconf.enable = true;

};}
