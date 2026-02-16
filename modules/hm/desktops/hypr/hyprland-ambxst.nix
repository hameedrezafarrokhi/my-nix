{ inputs, config, pkgs, lib, system, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-ambxst" config.my.rices-shells) {

  programs.quickshell = {
    enable = true;
    systemd.enable = false;
  };

 #systemd.user.services.caelestia-hypr = {
 #  Unit = {
 #    Description = "Caelestia Shell Service";
 #    After = ["graphical-session.target"];
 #    PartOf = ["graphical-session.target"];
 #   #ConditionEnvironment = "XDG_SESSION_DESKTOP=Hyprland-Caelestia";
 #    ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Caelestia";
 #  };
 #  Service = {
 #    Type = "exec";
 #    ExecStart = "${inputs.caelestia-shell.packages.${system}.default}/bin/caelestia-shell";
 #    Restart = "on-failure";
 #    RestartSec = "5s";
 #    TimeoutStopSec = "5s";
 #    Environment = [
 #      "QT_QPA_PLATFORM=wayland"
 #      "QT_QPA_PLATFORMTHEME=qt6ct"
 #    ];
 #    Slice = "session.slice";
 #  };
 #  Install = {
 #    WantedBy = ["graphical-session.target"];
 #  };
 #};

};}
