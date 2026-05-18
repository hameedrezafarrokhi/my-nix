{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.qvwm;
  qvwm = pkgs.callPackage ./qvwm.nix { };

in

{

  options = {
    services.xserver.windowManager.qvwm = {
      enable = mkEnableOption "qvwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before qvwm is started.
        '';
      };
      package = mkPackageOption pkgs "qvwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "qvwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "qvwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${qvwm}/bin/qvwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.qvwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = qvwm;
    };

  };

}
