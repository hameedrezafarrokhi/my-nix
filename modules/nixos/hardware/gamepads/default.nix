{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.gamepads;

in

{

  options.my.hardware.gamepads.enable = lib.mkEnableOption "enable gamepad support";

  config = lib.mkIf cfg.enable {

    hardware = {
      xone.enable = true;        # xone controller support
      xpadneo.enable = true;     # xone controller support
      xpad-noone.enable = true;  # x360 controller support
    };

  };

}
