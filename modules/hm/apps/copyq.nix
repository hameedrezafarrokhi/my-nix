{ config, pkgs, lib, ... }:

let

  copyq-config = pkgs.writeShellScriptBin "copyq-config" ''
    copyq config hide_main_window true
    copyq config disable_tray true
  '';

in

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
      ExecStartPost = "${copyq-config}/bin/copyq-config";
    };
    Unit = {
      ConditionEnvironment = "!XDG_SESSION_TYPE=wayland";
    };
  };

  home.packages = [
    copyq-config
  ];

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
