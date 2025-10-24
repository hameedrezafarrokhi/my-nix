{ inputs, config, pkgs, lib, nix-path-alt, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-exo" config.my.rices-shells) {

  programs.ignis = {
    enable = true;
    addToPythonEnv = true;
    configDir = ../../bar-shell/ignis/exo;           # exo config hard codes .config/ignis/ change it later maybe, if more ignis configs
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
     #ExecStart = "/etc/profiles/per-user/hrf/bin/ignis init -c ${nix-path-alt}/modules/hm/bar-shell/ignis/exo/config.py";
      Restart = "on-failure";
      Slice = "session.slice";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

};}
