{ config, pkgs, lib, ... }:

let

  cfg = config.my.security.keyring;

in

{

  options.my.security.keyring.enable = lib.mkEnableOption "enable keyrings";

  config = lib.mkIf cfg.enable {

    services = {

      gnome.gnome-keyring.enable = true;

    };

  };

}
