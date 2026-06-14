{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.gamepads;

in

{

  options.my.hardware.gamepads.enable = lib.mkEnableOption "enable gamepad support";

  config = lib.mkIf cfg.enable {

    hardware = {

      xone.enable = true;        # xone controller support

      xpad-noone.enable = true;  # x360 controller support

      xpadneo = {   # xone controller support
        enable = true;
       #settings = {  # Example
       #  disable_deadzones = 1;
       #  trigger_rumble_mode = 2;
       #  disable_shift_mode = 1;
       #};
       #quirks = { };
       #rumbleAttenuation = {
       #  triggers = null;  # 0-100
       #  overall = 0;
       #};
      };

    };

  };

}
