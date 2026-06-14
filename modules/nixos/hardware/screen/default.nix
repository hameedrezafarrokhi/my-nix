{ config, pkgs, lib, mypkgs, ... }:

let

  cfg = config.my.hardware.screen;

in

{

  options = {

    my.hardware.screen.enable = lib.mkEnableOption "enable screen stuff";

    programs.my-light = {

      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Whether to install Light backlight control command
          and udev rules granting access to members of the "video" group.
        '';
      };

      package = lib.mkOption {
        description = "gnulight package";
        type = lib.types.package;
       #default = mypkgs.;
      };

      brightnessKeys = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to enable brightness control with keyboard keys.

            This is mainly useful for minimalistic (desktop) environments. You
            may want to leave this disabled if you run a feature-rich desktop
            environment such as KDE, GNOME or Xfce as those handle the
            brightness keys themselves. However, enabling brightness control
            with this setting makes the control independent of X, so the keys
            work in non-graphical ttys, so you might want to consider using this
            instead of the default offered by the desktop environment.

            Enabling this will turn on {option}`services.actkbd`.
          '';
        };

        step = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = ''
            The percentage value by which to increase/decrease brightness.
          '';
        };

        minBrightness = lib.mkOption {
          type = lib.types.numbers.between 0 100;
          default = 0.1;
          description = ''
            The minimum authorized brightness value, e.g. to avoid the
            display going dark.
          '';
        };

      };

    };

  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [

      pkgs.gnome-color-manager
      pkgs.colord-gtk
     #pkgs.kdePackages.colord-kde
      pkgs.brightnessctl
      pkgs.ddcutil

      config.programs.my-light.package

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
      my-light = {            # DEPRICATED (But Polybar Light Module depends on it, make an alternative module for polybar before removing this)
        enable = true;
        package = mypkgs.old-stable.light;
        brightnessKeys = {
          enable = true;   # illum handles this for me
          minBrightness = 0.1;
          step = 2;
        };
      };
    };

   #environment.systemPackages = [ config.programs.my-light.package ];
    services.udev.packages = [ config.programs.my-light.package ];
    services.actkbd = lib.mkIf config.programs.my-light.brightnessKeys.enable {
      enable = true;
      bindings =
        let
          light = "${config.programs.my-light.package}/bin/light";
          step = toString config.programs.my-light.brightnessKeys.step;
          minBrightness = toString config.programs.my-light.brightnessKeys.minBrightness;
        in
        [
          {
            keys = [ 224 ];
            events = [ "key" ];
            # -N is used to ensure that value >= minBrightness
            command = "${light} -N ${minBrightness} && ${light} -U ${step}";
          }
          {
            keys = [ 225 ];
            events = [ "key" ];
            command = "${light} -A ${step}";
          }
        ];
    };

  };

}
