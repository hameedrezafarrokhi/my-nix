{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "pantheon" config.my.desktops) {

  services.desktopManager.pantheon = {
    enable = true;
   #sessionPath = [ ];
   #extraWingpanelIndicators = [ ];
   #extraSwitchboardPlugs = [ ];
   #extraGSettingsOverrides = "";
   #extraGSettingsOverridePackages = [ ];
   #debug = false;
  };

  services.pantheon = {
    apps.enable = true;
    contractor.enable = true;
  };

   environment.pantheon.excludePackages = [ ];

};}
