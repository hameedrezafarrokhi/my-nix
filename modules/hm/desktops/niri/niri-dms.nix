{ config, pkgs, lib, ... }:

let


in

{ config = lib.mkIf (builtins.elem "niri-dms" config.my.rices-shells) {

  programs.quickshell = {
    enable = true;
    systemd.enable = false;
  };

  programs.dankMaterialShell = {
    enable = true;
    enableSystemd = true;
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
      ConditionEnvironment = "DESKTOP_SESSION=Niri-DMS";
    };
    Service = {
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_QPA_PLATFORMTHEME=qt6ct"
      ];
    };
  };

 #systemd.user.services.dms-niri = {
 #    Unit = {
 #        Description = "DankMaterialShell";
 #        PartOf = [ config.wayland.systemd.target ];
 #        After = [ config.wayland.systemd.target ];
 #        ConditionEnvironment = "DESKTOP_SESSION=Niri-DMS";
 #    };
 #    Service = {
 #        ExecStart = "dms run -d";
 #        Restart = "on-failure";
 #    };
 #    Install.WantedBy = [ config.wayland.systemd.target ];
 #};


};}
