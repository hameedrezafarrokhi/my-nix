{ config, pkgs, lib, ... }:

let

  cfg = config.my.dwm;

in

{

  options.my.dwm.enable = lib.mkEnableOption "dwm";

  config = lib.mkIf cfg.enable {

    services.dwm-status = {

      enable = false;
      package = pkgs.dwm-status;
      order = [ "audio" "backlight" "battery" "cpu_load" "network" "time" ]; # list of (one of "audio", "backlight", "battery", "cpu_load", "network", "time")
      extraConfig = {
       #separator = "#";
       #battery = {
       #  notifier_levels = [ 2 5 10 15 20 ];
       #};
        time = {
          format = "%H:%M";
        };
      };

    };

  };

}
