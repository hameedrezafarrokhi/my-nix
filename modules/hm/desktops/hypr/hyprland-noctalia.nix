{ inputs, config, pkgs, lib, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-noctalia" config.my.rices-shells) {

  programs.quickshell = {
    enable = true;
    systemd.enable = false;
    configs.noctalia-shell = inputs.noctalia-shell;
  };

  systemd.user.services.noctalia-hypr = {
    Unit = {
      Description = "Noctalia Shell Service";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
     #ConditionEnvironment = "XDG_SESSION_DESKTOP=Hyprland-Caelestia";
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Noctalia";
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
