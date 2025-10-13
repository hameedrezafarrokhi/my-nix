{ config, pkgs, lib, inputs, ... }:

let


in

{ config = lib.mkIf (builtins.elem "niri-noctalia" config.my.rices-shells) {

  programs.quickshell = {
    enable = true;
    systemd.enable = false;
    configs.noctalia-shell = inputs.noctalia-shell;
  };

  systemd.user.services.noctalia-niri-uwsm = {
    Unit = {
      Description = "Noctalia Shell Service";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
     #ConditionEnvironment = "XDG_SESSION_DESKTOP=Hyprland-Caelestia";
      ConditionEnvironment = "DESKTOP_SESSION=Niri-Noctalia-uwsm";
    };
    Service = {
      Type = "exec";
      ExecStart = lib.getExe (config.programs.quickshell.package) + (" --config ${inputs.noctalia-shell}/");
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

  systemd.user.services.noctalia-niri = {
    Unit = {
      Description = "Noctalia Shell Service";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
     #ConditionEnvironment = "XDG_SESSION_DESKTOP=Hyprland-Caelestia";
      ConditionEnvironment = "DESKTOP_SESSION=Niri-Noctalia";
    };
    Service = {
      Type = "exec";
      ExecStart = lib.getExe (config.programs.quickshell.package) + (" --config ${inputs.noctalia-shell}/");
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
