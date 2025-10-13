{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.nm-applet.enable) {

  programs.nm-applet = {
    enable = true;
    indicator = lib.mkForce true;
  };

  systemd.user.services = {
    nm-applet.serviceConfig.ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER i3 || pgrep -u $USER sway || || pgrep -u $USER bspwm'";
  };

};}
