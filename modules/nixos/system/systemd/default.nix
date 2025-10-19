{ config, pkgs, lib, ... }:

let

  cfg = config.my.systemd;

in

{

  options.my.systemd.enable = lib.mkEnableOption "systemd config";

  config = {

    systemd.user.extraConfig = ''

      DefaultTimeoutStopSec=5s

    '';

  };

}
