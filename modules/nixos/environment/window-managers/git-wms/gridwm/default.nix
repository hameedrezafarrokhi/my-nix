{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.gridwm;
  gridwm = pkgs.callPackage ./gridwm.nix { };

in

{

  options = {
    services.xserver.windowManager.gridwm = {
      enable = mkEnableOption "gridwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before gridwm is started.
        '';
      };
      package = mkPackageOption pkgs "gridwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "gridwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "gridwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${gridwm}/bin/subtle &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.gridwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = gridwm;
    };

  };

}
