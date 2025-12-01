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

  };

}
