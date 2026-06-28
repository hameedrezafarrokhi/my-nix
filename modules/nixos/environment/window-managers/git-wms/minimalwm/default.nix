{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.minimalwm;
  minimalwm = pkgs.callPackage ./minimalwm.nix { };

in

{

  options = {
    services.xserver.windowManager.minimalwm = {
      enable = mkEnableOption "minimalwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before minimalwm is started.
        '';
      };
      package = mkPackageOption pkgs "minimalwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "minimalwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "minimalwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${minimalwm}/bin/mwmp &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.minimalwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = minimalwm;
    };

  };

}
