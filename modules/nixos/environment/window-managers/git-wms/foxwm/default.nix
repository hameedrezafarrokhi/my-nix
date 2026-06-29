{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.foxwm;
  foxwm = pkgs.callPackage ./foxwm.nix { };

in

{

  options = {
    services.xserver.windowManager.foxwm = {
      enable = mkEnableOption "foxwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before foxwm is started.
        '';
      };
      package = mkPackageOption pkgs "foxwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "foxwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "foxwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${foxwm}/bin/foxwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.foxwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = foxwm;
    };

  };

}
