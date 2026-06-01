{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.better-control.enable) {

  home.packages = [
    pkgs.better-control
    pkgs.usbguard
  ];

  xdg.configFile = {
    "better-control/settings.json".text = builtins.toJSON {
      "visibility" = {};
      "positions" = {};
      "usbguard_hidden_devices" = [];
      "language" = "en";
      "vertical_tabs" = true;
      "vertical_tabs_icon_only" = true;
    };
   #"better-control/power_settings.json".text = builtins.toJSON {
   #};
  };

};}
