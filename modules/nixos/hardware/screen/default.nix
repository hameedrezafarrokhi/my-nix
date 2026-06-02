{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.screen;

in

{

  options.my.hardware.screen.enable = lib.mkEnableOption "enable screen stuff";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [

      pkgs.gnome-color-manager
      pkgs.colord-gtk
     #pkgs.kdePackages.colord-kde
      pkgs.brightnessctl
      pkgs.ddcutil

    ];

    hardware.acpilight.enable = true;

    services = {
      illum.enable = true;
      colord.enable = true;
     #redshift = {
     #  enable = true;
     #  package = pkgs.redshift;           #pkg override, lots of options
     #  executable = "/bin/redshift-gtk";
     # #extraOptions = [  ];
     #  temperature = {
     #    day = 5500;
     #    night = 3700;
     #  };
     #  brightness = {
     #    day = "1";
     #    night = "0.5";
     #};
    };

    programs = {
      light = {            # DEPRICATED (But Polybar Light Module depends on it, make an alternative module for polybar before removing this)
        enable = true;
        brightnessKeys = {
          enable = true;   # illum handles this for me
          minBrightness = 0.1;
          step = 2;
        };
      };
    };

  };

}
