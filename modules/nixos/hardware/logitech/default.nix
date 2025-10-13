{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.logitech;

in

{

  options.my.hardware.logitech.enable = lib.mkEnableOption "enable logi peripherals";

  config = lib.mkIf cfg.enable {

    hardware.logitech = {
      wireless = {
        enable = true;
        enableGraphical = true;
      };
    };

  };

}
