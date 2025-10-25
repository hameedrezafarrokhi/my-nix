{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.screen;

in

{

  options.my.hardware.screen.enable = lib.mkEnableOption "enable screen stuff";

  config = lib.mkIf cfg.enable {

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

  };

}
