{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.srwm;
  srwm = pkgs.callPackage ./srwm.nix { };

in

{

  options = {
    services.xserver.windowManager.srwm = {
      enable = mkEnableOption "srwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before srwm is started.
        '';
      };
      package = mkPackageOption pkgs "srwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "srwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "srwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${srwm}/bin/srwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.srwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = srwm;
    };

  };

}
