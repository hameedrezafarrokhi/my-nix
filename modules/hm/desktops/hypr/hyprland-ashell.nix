{ inputs, config, pkgs, lib, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-ashell" config.my.rices-shells) {

  systemd.user.services.ashell-hyprland = {
    Unit = {
      Description = "ashell status bar";
      Documentation = "https://github.com/MalpenZibo/ashell/tree/0.4.1";
      After = [ config.programs.ashell.systemd.target ];
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Ashell";
    };
    Service = {
      ExecStart = "${lib.getExe config.programs.ashell.package}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ config.programs.ashell.systemd.target ];
  };

  systemd.user.services.ashell-hyprland-uwsm = {
    Unit = {
      Description = "ashell status bar";
      Documentation = "https://github.com/MalpenZibo/ashell/tree/0.4.1";
      After = [ config.programs.ashell.systemd.target ];
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Ashell-uwsm";
    };
    Service = {
      ExecStart = "${lib.getExe config.programs.ashell.package}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ config.programs.ashell.systemd.target ];
  };

};}
