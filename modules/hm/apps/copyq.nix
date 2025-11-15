{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.copyq.enable) {

  services.copyq = {
    enable = true;
    package = pkgs.copyq;
    forceXWayland = true;
    systemdTarget = "graphical-session.target";
  };

  systemd.user.services.copyq = {
    Unit = {
      ConditionEnvironment = "!XDG_SESSION_TYPE=wayland";
    };
  };

};}
