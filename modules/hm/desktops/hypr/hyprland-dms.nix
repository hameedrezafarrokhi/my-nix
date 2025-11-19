{ inputs, config, pkgs, lib, /*dmsPkgs,*/ ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-dms" config.my.rices-shells) {

  programs.quickshell = {
    enable = true;
    systemd.enable = false;
  };

  programs.dankMaterialShell = {
    enable = true;
    systemd.enable = true;
    enableClipboard = true;
    enableVPN = true;
    enableBrightnessControl = true;
   #enableNightMode = true;          # Removed Option
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
   #quickshell.package = ;
   #plugins = { };
   #default = {
   #  settings = { };
   #  session = { };
   #};
  };

  systemd.user.services.dms = {
    Unit = {
      ConditionEnvironment = "DESKTOP_SESSION=none";
    };
    Service = {
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_QPA_PLATFORMTHEME=qt6ct"
      ];
    };
  };

  systemd.user.services.dms-hyprland = {
    Unit = {
      Description = "DankMaterialShell";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-DMS";
    };
    Service = {
      Type = "exec";
      ExecStart = "dms run";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "5s";
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_QPA_PLATFORMTHEME=qt6ct"
      ];
     Slice = "session.slice";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

};}
