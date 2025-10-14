{ config, pkgs, lib, inputs, ... }:

  with lib.hm.gvariant;

{ config = lib.mkIf (config.my.apps.onboard.enable) {

  dconf.settings = {

    "org/onboard" = {
     #schema-version = "2.3";
      show-status-icon = true;
      show-tooltips = true;
      status-icon-provider = "auto";
     #system-theme-associations = {
     #  HighContrast = "HighContrast";
     #  HighContrastInverse = "HighContrastInverse";
     #  LowContrast = "LowContrast";
     #  ContrastHighInverse = "HighContrastInverse";
     #  Default = "";
     #  Nordic-darker = "/home/hrf/.local/share/onboard/themes/ModelM.theme";
     #};
      use-system-defaults = false;
    };

    "org/onboard/icon-palette" = {
      in-use = true;
    };

    "org/onboard/icon-palette/landscape" = {
      height = 20;
      width = 20;
      x = 1345;
      y = 30;
    };

    "org/onboard/keyboard" = {
      audio-feedback-enabled = false;
      input-event-source = "XInput";
      touch-feedback-enabled = true;
      touch-feedback-size = 0;
    };

    "org/onboard/window" = {
      docking-enabled = false;
      force-to-top = true;
    };

    "org/onboard/window/landscape" = {
      height = 183;
      width = 504;
      x = 862;
      y = 27;
    };

  };

  home.packages = [
    pkgs.onboard
  ];

  xdg.desktopEntries = {

    "onboard-xwayland" = {
      name="Onboard-xwayland";
      genericName="Onboard onscreen keyboard";
      comment="Flexible onscreen-xwayland keyboard";
      terminal=false;
      type="Application";
     #exec="GDK_BACKEND=x11 onboard";
      exec="env GDK_BACKEND=x11 ${pkgs.onboard}/bin/onboard";
      categories=["Utility" "Accessibility"];
      mimeType=["application/x-onboard"];
      icon="${inputs.assets}/icons/keyboard-purple.svg";
      startupNotify = null;
      prefersNonDefaultGPU = null;
      noDisplay = false;
     #settings = { DBusActivatable = "false"; "X-Ubuntu-Gettext-Domain=onboard"; };
     #actions = {};
    };

   #"onboard-settings-xwayland" = {
   #  name="Onboard-settings-xwayland";
   #  exec="GDK_BACKEND=x11 onboard-settings";
   #  categories=["System"];
   #  icon=../../assets/keyboard-svgrepo-com.svg;
   #};

  };

};}
