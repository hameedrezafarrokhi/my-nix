{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.wmwm;
  wmwm = pkgs.callPackage ./wmwm.nix { };

in

{

  options = {
    services.xserver.windowManager.wmwm = {
      enable = mkEnableOption "wmwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before wmwm is started.
        '';
      };
      package = mkPackageOption pkgs "wmwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "wmwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "wmwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${wmwm}/bin/wmwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.wmwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = wmwm;
    };

  };

}
