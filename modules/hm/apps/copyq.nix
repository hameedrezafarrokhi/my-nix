{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.copyq.enable) {

  services.copyq = {
    enable = true;
    package = pkgs.copyq;
    forceXWayland = true;
    systemdTarget = "graphical-session.target";
  };

  systemd.user.services.copyq = {
    Service = {
      MemoryHigh = "350M";
      MemoryMax = "400M";
      TimeoutStopSec = "30s";
      RestartSec = "5s";
    };
    Unit = {
      ConditionEnvironment = "!XDG_SESSION_TYPE=wayland";
    };
  };

  # opens a window on start if tray is disabled
 #xdg.configFile.copyq-conf = {
 #  target = "copyq/copyq.conf";
 #  text = ''
 #    [Options]
 #    tabs=&clipboard
 #    disable_tray=true
 #  '';
 #};

};}
