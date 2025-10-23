{ inputs, config, pkgs, lib, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-exo" config.my.rices-shells) {

  programs.ignis = {
    enable = true;
    addToPythonEnv = true;
   #configDir = ./ignis;
    services = {
      bluetooth.enable = true;
      recorder.enable = true;
      audio.enable = true;
      network.enable = true;
    };
    sass = {
      enable = true;
      useDartSass = true;
    };
   #extraPackages = ;
  };

  systemd.user.services.exo-hyprland = {
    Unit = {
      Description = "exo shell";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Exo";
    };
    Service = {
     #Type = "exec";
      RestartSec = "5s";
      TimeoutStopSec = "5s";
      ExecStart = "/etc/profiles/per-user/hrf/bin/ignis init";
      Restart = "on-failure";
      Slice = "session.slice";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

};}
