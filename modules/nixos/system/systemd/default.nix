{ config, pkgs, lib, admin, ... }:

let

  cfg = config.my.systemd;

  # WARNING KERNEL BUG REMOVE AFTER UPDATE
  kern-bug = pkgs.writeShellScriptBin "kern-bug" ''
    # WARNING , THIS IS A KERNEL BUG , REMOVE AFTER UPDATE (Qt Apps Lock Scroll After Sleep)
    # cat /proc/sys/fs/inotify/max_user_watches
    sudo sysctl fs.inotify.max_user_watches=1048576
    sudo modprobe -r usbhid
    sudo modprobe usbhid
    sleep 2
    xset r rate ${config.home-manager.users.${admin}.my.x11.xrate}
  '';

in

{

  options.my.systemd.enable = lib.mkEnableOption "systemd config";

  config = lib.mkIf config.my.systemd.enable {

   #systemd.user.extraConfig = ''
   #
   #  DefaultTimeoutStopSec=5s
   #
   #'';

    environment.systemPackages = [

      pkgs.systemd-manager-tui
      pkgs.systemd-lock-handler
      pkgs.rofi-systemd
      pkgs.systemd-wait
      pkgs.systemd-bootchart
      pkgs.isd
      pkgs.journalwatch
      pkgs.systemctl-tui

      (pkgs.writeShellScriptBin "systemctltui" ''${config.my.default.terminal} --name systemctltui --class systemctltui sh -c 'systemctl-tui' '')

      kern-bug

    ];


    # WARNING KERNEL BUG REMOVE AFTER UPDATE

   #boot.kernel.sysctl = {
   # #"fs.inotify.max_user_watches" = 1048576;
   #  "fs.inotify.max_user_watches" = 15048576; #524288
   #  "fs.inotify.max_user_instances" = 1048576; #524288
   #  "fs.inotify.max_queued_events" = 168576; #16384
   #};

   #systemd.user.services.fix-kern-qt-sleep-bug = {
   #  Unit = {
   #    Description = "fix-kern-qt-sleep-bug";
   #    After = [ "sleep.target" ];
   #  };
   #  Service = {
   #    Type = "oneshot";
   #    ExecStart = "${kern-bug}/bin/kern-bug";
   #   #RemainsAfterExit = "no";
   #  };
   #  Install = {
   #    WantedBy = ["sleep.target"];
   #  };
   #};

   #systemd.services.fix-kern-qt-sleep-bug = {
   #  description = "fix-kern-qt-sleep-bug";
   #  after = [ "sleep.target" ];
   #  wantedBy = ["sleep.target"];
   #  serviceConfig = {
   #    Type = "oneshot";
   #    ExecStart = "${kern-bug}/bin/kern-bug";
   #  };
   #};

  };

}
