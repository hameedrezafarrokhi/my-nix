{ config, pkgs, lib, ... }:

let

  cfg = config.my.systemd;

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

    ];

  };

}
